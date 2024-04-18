//
//  CommunityListModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-18.
//

import Combine
import Dependencies
import Foundation

class CommunityListModel: ObservableObject {
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.notifier) var notifier
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var allSections: [CommunityListSection] = .init()
    @Published private(set) var visibleSections: [CommunityListSection] = .init()
    
    private(set) var subscribed: [APICommunity] = .init()
    private var subscribedSet: Set<Int> = .init()
    private(set) var favorited: [APICommunity] = .init()
    private var favoritedSet: Set<Int> = .init()
    
    init() {
        favoriteCommunitiesTracker
            .$favoritesForCurrentAccount
            .dropFirst()
            .sink { [weak self] value in
                if let self {
                    Task {
                        await self.updateFavorites(value)
                    }
                }
            }
            .store(in: &cancellables)
        let (newAllSections, newVisibleSections) = recomputeSections()
        self.allSections = newAllSections
        self.visibleSections = newVisibleSections
    }
    
    func load() async {
        do {
            // load our subscribed communities
            let newSubscribed = try await communityRepository
                .loadSubscriptions()
                .map(\.community)
            
            // load our favourite communities
            let newFavorited = favoriteCommunitiesTracker.favoritesForCurrentAccount
            
            // combine the two lists
            await update(newSubscribed, newFavorited)
        } catch {
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
    
    func isSubscribed(to community: APICommunity) -> Bool {
        subscribedSet.contains(community.id)
    }
    
    func updateSubscriptionStatus(for community: APICommunity, subscribed: Bool) async {
        // immediately update our local state
        await updateLocalStatus(for: community, subscribed: subscribed)
        
        // then attempt to update our remote state
        Task {
            await updateRemoteStatus(for: community, subscribed: subscribed)
        }
    }
    
    private func updateLocalStatus(for community: APICommunity, subscribed: Bool) async {
        var newSubscribed = self.subscribed
        
        if subscribed {
            newSubscribed.append(community)
        } else {
            if !subscribedSet.contains(community.id) {
                assertionFailure("Tried to unsubscribe from already unsubscribed community \(community.fullyQualifiedName)")
            }
            if let index = newSubscribed.firstIndex(where: { $0 == community }) {
                newSubscribed.remove(at: index)
            }
        }
        
        await update(newSubscribed, favorited)
    }
    
    private func updateRemoteStatus(for community: APICommunity, subscribed: Bool) async {
        do {
            let updatedCommunity = try await communityRepository.updateSubscription(for: community.id, subscribed: subscribed).community
            
            if subscribed {
                await notifier.add(.success("Subscibed to \(community.name)"))
            } else {
                await notifier.add(.success("Unsubscribed from \(community.name)"))
            }
            
            if let indexToUpdate = self.subscribed.firstIndex(where: { $0.id == updatedCommunity.id }) {
                var newSubscribed = self.subscribed
                newSubscribed[indexToUpdate] = updatedCommunity
                await update(newSubscribed, favorited)
            }
        } catch {
            let phrase = subscribed ? "subscribe to" : "unsubscribe from"
            errorHandler.handle(
                .init(
                    title: "Unable to \(phrase) community",
                    style: .toast,
                    underlyingError: error
                )
            )
            
            // as the call failed, we need to revert the change to the local state
            await updateLocalStatus(for: community, subscribed: !subscribed)
        }
    }
    
    private func updateFavorites(_ favorites: [APICommunity]) async {
        await update(subscribed, favorites)
    }
    
    private func update(_ subscribed: [APICommunity], _ favorited: [APICommunity]) async {
        // store the values for future use
        self.subscribed = subscribed
        subscribedSet = Set(subscribed.map(\.id))
        self.favorited = favorited
        favoritedSet = Set(favorited.map(\.id))
  
        let (newAllSections, newVisibleSections) = recomputeSections()
        await MainActor.run {
            self.allSections = newAllSections
            self.visibleSections = newVisibleSections
        }
    }
    
    // swiftlint:disable:next function_body_length
    private func recomputeSections() -> (all: [CommunityListSection], visible: [CommunityListSection]) {
        var newAllSections: [CommunityListSection] = .init()
        var newVisibleSections: [CommunityListSection] = .init()
        
        let topSection = withDependencies(from: self) {
            CommunityListSection(
                viewId: "top",
                sidebarEntry: EmptySidebarEntry(
                    sidebarLabel: nil,
                    sidebarIcon: "line.3.horizontal"
                ),
                inlineHeaderLabel: nil,
                accessibilityLabel: "Top of communities",
                communities: .init()
            )
        }
        newAllSections.append(topSection)
        
        let favoritesSection = withDependencies(from: self) {
            CommunityListSection(
                viewId: "favorites",
                sidebarEntry: FavoritesSidebarEntry(
                    sidebarLabel: nil,
                    sidebarIcon: "star.fill"
                ),
                inlineHeaderLabel: "Favorites",
                accessibilityLabel: "Favorited Communities",
                communities: favorited
            )
        }
        newAllSections.append(favoritesSection)
        if !favoritedSet.isEmpty {
            newVisibleSections.append(favoritesSection)
        }
        
        let alphabeticSections = alphabeticSections()
        newAllSections.append(contentsOf: alphabeticSections)
        newVisibleSections.append(contentsOf: alphabeticSections.filter { section in
            !section.communities.isEmpty
        })
        
        let nonLetterSections = withDependencies(from: self) {
            let sidebarEntry = RegexCommunityNameSidebarEntry(
                communityNameRegex: /^[^a-zA-Z]/,
                sidebarLabel: "#",
                sidebarIcon: nil
            )
            
            return CommunityListSection(
                viewId: "non_letter_titles",
                sidebarEntry: sidebarEntry,
                inlineHeaderLabel: "#",
                accessibilityLabel: "Communities starting with a symbol or number",
                communities: subscribed.filter { community in
                    sidebarEntry.contains(community: community, isSubscribed: true)
                }
            )
        }
        newAllSections.append(nonLetterSections)
        if !nonLetterSections.communities.isEmpty {
            newVisibleSections.append(nonLetterSections)
        }
        
        return (all: newAllSections, visible: newVisibleSections)
    }
    
    private func alphabeticSections() -> [CommunityListSection] {
        let alphabet: [String] = .alphabet
        return alphabet.map { character in
            withDependencies(from: self) {
                let sidebarEntry = RegexCommunityNameSidebarEntry(
                    communityNameRegex: (try? Regex("^[\(character.uppercased())\(character.lowercased())]"))!,
                    sidebarLabel: character,
                    sidebarIcon: nil
                )
                
                // This looks sinister but I didn't know how to string replace in a non-string based regex
                return CommunityListSection(
                    viewId: character,
                    sidebarEntry: sidebarEntry,
                    inlineHeaderLabel: character,
                    accessibilityLabel: "Communities starting with the letter '\(character)'",
                    communities: subscribed.filter { community in
                        sidebarEntry.contains(community: community, isSubscribed: true)
                    }
                )
            }
        }
    }
}
