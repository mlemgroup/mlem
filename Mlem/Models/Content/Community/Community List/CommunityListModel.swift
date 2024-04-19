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
    
    init() {
        favoriteCommunitiesTracker
            .$favoritesForCurrentAccount
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
        subscribedSet = Set(subscribed.lazy.map(\.id))
        self.favorited = favorited.sorted()
  
        let (newAllSections, newVisibleSections) = recomputeSections()
        await MainActor.run {
            self.allSections = newAllSections
            self.visibleSections = newVisibleSections
        }
    }
    
    private func recomputeSections() -> (all: [CommunityListSection], visible: [CommunityListSection]) {
        var newAllSections: [CommunityListSection] = .init()
        var newVisibleSections: [CommunityListSection] = .init()
        
        let topSection = withDependencies(from: self) {
            CommunityListSection(
                viewId: "top",
                sidebarEntry: .init(sidebarLabel: nil, sidebarIcon: "line.3.horizontal"),
                inlineHeaderLabel: nil,
                accessibilityLabel: "Top of communities",
                communities: .init()
            )
        }
        newAllSections.append(topSection)
        
        let favoritesSection = withDependencies(from: self) {
            CommunityListSection(
                viewId: "favorites",
                sidebarEntry: .init(sidebarLabel: nil, sidebarIcon: "star.fill"),
                inlineHeaderLabel: "Favorites",
                accessibilityLabel: "Favorited Communities",
                communities: favorited
            )
        }
        newAllSections.append(favoritesSection)
        if !favorited.isEmpty {
            newVisibleSections.append(favoritesSection)
        }
        
        let alphabeticSections = alphabeticSections()
        
        newAllSections.append(contentsOf: alphabeticSections)
        newVisibleSections.append(contentsOf: alphabeticSections.filter { section in
            !section.communities.isEmpty
        })
        
        return (all: newAllSections, visible: newVisibleSections)
    }
    
    private func alphabeticSections() -> [CommunityListSection] {
        let sections: [String: [APICommunity]] = .init(
            grouping: subscribed,
            by: { item in
                if let first = item.name.first, first.isLetter {
                    return first.uppercased()
                }
                return "#"
            }
        )
        
        assert(sections.values.reduce(0) { x, communities in
            x + communities.count
        } == subscribed.count, "mapping operation produced mismatched counts")
        
        return sections.keys.sorted().map { character in
            CommunityListSection(
                viewId: character,
                sidebarEntry: .init(sidebarLabel: character, sidebarIcon: nil),
                inlineHeaderLabel: character,
                accessibilityLabel: "Communities starting with \(character == "#" ? "a symbol or number" : character)",
                communities: sections[character, default: .init()].sorted()
            )
        }
    }
}
