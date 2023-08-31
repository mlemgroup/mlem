// 
//  CommunityListModel.swift
//  Mlem
//
//  Created by mormaer on 11/08/2023.
//  
//

import Combine
import Dependencies
import Foundation

class CommunityListModel: ObservableObject {
    
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.notifier) var notifier
    @Dependency(\.mainQueue) var mainQueue
    
    @Published private(set) var communities = [APICommunity]()
    
    private var subscriptions = [APICommunity]()
    private var favoriteCommunities = [APICommunity]()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        favoriteCommunitiesTracker
            .$favoritesForCurrentAccount
            .dropFirst()
            .sink { [weak self] value in
                self?.updateFavorites(value)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public methods
    
    func load() async {
        do {
            // load our subscribed communities
            let subscriptions = try await communityRepository
                .loadSubscriptions()
                .map { $0.community }
            
            // load our favourite communities
            let favorites = favoriteCommunitiesTracker.favoritesForCurrentAccount.map { $0.community }
            
            // combine the two lists
            combine(subscriptions, favorites)
        } catch {
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
    
    func isSubscribed(to community: APICommunity) -> Bool {
        subscriptions.contains(community)
    }
    
    func updateSubscriptionStatus(for community: APICommunity, subscribed: Bool) {
        // immediately update our local state
        updateLocalStatus(for: community, subscribed: subscribed)
        
        // then attempt to update our remote state
        Task {
            await updateRemoteStatus(for: community, subscribed: subscribed)
        }
    }
    
    var visibleSections: [CommunitySection] {
        allSections()
        
        // Only show sections which have labels to show
            .filter { communitySection -> Bool in
                communitySection.inlineHeaderLabel != nil
            }
        
        // Only show letter headers for letters we have in our community list
            .filter { communitySection -> Bool in
                communities
                    .contains(where: { communitySection.sidebarEntry
                        .contains(community: $0, isSubscribed: isSubscribed(to: $0)) })
            }
    }
    
    func communities(for section: CommunitySection) -> [APICommunity] {
        // Filter down to sidebar entry which wants us
        return communities
            .filter { community -> Bool in
                section.sidebarEntry.contains(community: community, isSubscribed: isSubscribed(to: community))
            }
    }
    
    func allSections() -> [CommunitySection] {
        var sections = [CommunitySection]()
        
        sections.append(
            withDependencies(from: self) {
                CommunitySection(
                    viewId: "top",
                    sidebarEntry: EmptySidebarEntry(
                        sidebarLabel: nil,
                        sidebarIcon: "line.3.horizontal"
                    ),
                    inlineHeaderLabel: nil,
                    accessibilityLabel: "Top of communities"
                )
            }
        )
        
        sections.append(
            withDependencies(from: self) {
                CommunitySection(
                    viewId: "favorites",
                    sidebarEntry: FavoritesSidebarEntry(
                        sidebarLabel: nil,
                        sidebarIcon: "star.fill"
                    ),
                    inlineHeaderLabel: "Favorites",
                    accessibilityLabel: "Favorited Communities"
                )
            }
        )
        
        sections.append(contentsOf: alphabeticSections())
        
        sections.append(
            withDependencies(from: self) {
                CommunitySection(
                    viewId: "non_letter_titles",
                    sidebarEntry: RegexCommunityNameSidebarEntry(
                        communityNameRegex: /^[^a-zA-Z]/,
                        sidebarLabel: "#",
                        sidebarIcon: nil
                    ),
                    inlineHeaderLabel: "#",
                    accessibilityLabel: "Communities starting with a symbol or number"
                )
            }
        )
        
        return sections
    }
    
    func alphabeticSections() -> [CommunitySection] {
        let alphabet: [String] = .alphabet
        return alphabet.map { character in
            withDependencies(from: self) {
                // This looks sinister but I didn't know how to string replace in a non-string based regex
                CommunitySection(
                    viewId: character,
                    sidebarEntry: RegexCommunityNameSidebarEntry(
                        communityNameRegex: (try? Regex("^[\(character.uppercased())\(character.lowercased())]"))!,
                        sidebarLabel: character,
                        sidebarIcon: nil
                    ),
                    inlineHeaderLabel: character,
                    accessibilityLabel: "Communities starting with the letter '\(character)'"
                )
            }
        }
    }
    
    // MARK: - Private methods
    
    private func updateLocalStatus(for community: APICommunity, subscribed: Bool) {
        var updatedSubscriptions = subscriptions
        
        if subscribed {
            updatedSubscriptions.append(community)
        } else {
            if let index = updatedSubscriptions.firstIndex(where: { $0 == community }) {
                updatedSubscriptions.remove(at: index)
            }
        }
        
        combine(updatedSubscriptions, favoriteCommunities)
    }
    
    private func updateRemoteStatus(for community: APICommunity, subscribed: Bool) async {
        do {
            let updatedCommunity = try await communityRepository.updateSubscription(for: community.id, subscribed: subscribed).community
            
            if subscribed {
                await notifier.add(.success("Subscibed to \(community.name)"))
            } else {
                await notifier.add(.success("Unsubscribed from \(community.name)"))
            }
            
            if let indexToUpdate = subscriptions.firstIndex(where: { $0.id == updatedCommunity.id }) {
                var updatedSubscriptions = subscriptions
                updatedSubscriptions[indexToUpdate] = updatedCommunity
                combine(updatedSubscriptions, favoriteCommunities)
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
            await MainActor.run {
                updateLocalStatus(for: community, subscribed: !subscribed)
            }
        }
    }
    
    private func updateFavorites(_ favorites: [FavoriteCommunity]) {
        combine(subscriptions, favorites.map { $0.community })
    }
    
    private func combine(_ subscriptions: [APICommunity], _ favorites: [APICommunity]) {
        // store the values for future use...
        self.subscriptions = subscriptions
        self.favoriteCommunities = favorites
        
        // combine and sort the two lists, excluding duplicates
        let combined = subscriptions + favorites.filter { !subscriptions.contains($0) }
        let sorted = combined.sorted()
        
        // update our published value for the view to render
        mainQueue.schedule { [weak self] in
            self?.communities = sorted
        }
    }
}
