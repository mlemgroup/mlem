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
        let alphabetSet = Set([String].alphabet)
        let sectionTitles: [String] = .alphabet
        
        var communities: [String: [APICommunity]] = .init()
        communities["other"] = .init()
        communities[sectionTitles[0]] = .init()
        
        let sortedCommunities = subscribed.sorted()
        var currentSectionIndex = 0
        var currentSectionTitle: String = sectionTitles[0]
        
        // iterate through sorted communities, building up each letter's section
        // it's not guaranteed that non-alphabetics be sorted to one side or the other of the alphabetics, so each element does have to be individually checked, hence the quick-lookup alphabetSet. They will be grouped, however, so branch prediction ought to make the performance impact of the conditional negligible
        for community in sortedCommunities {
            assert(community.name.first != nil, "\(community.name) has no first character!")
            if !alphabetSet.contains(String(community.name.first!.uppercased())) {
                assert(communities.keys.contains("other"), "No 'other' key in communities!")
                communities["other"]?.append(community)
            } else {
                while currentSectionIndex < 26, !community.name.uppercased().starts(with: currentSectionTitle) {
                    currentSectionIndex += 1
                    currentSectionTitle = sectionTitles[currentSectionIndex]
                    communities[currentSectionTitle] = .init()
                }
                assert(communities.keys.contains(currentSectionTitle), "No '\(currentSectionTitle)' key in communities!")
                communities[currentSectionTitle]?.append(community)
            }
        }
        
        assert(communities.values.reduce(0) { x, community in
            x + community.count
        } == subscribed.count, "mapping operation produced mismatched counts")
        
        let alphabet: [String] = .alphabet
        
        var ret: [CommunityListSection] = .init()
        
        ret.append(
            CommunityListSection(
                viewId: "non_letter_titles",
                sidebarEntry: .init(sidebarLabel: "#", sidebarIcon: nil),
                inlineHeaderLabel: "#",
                accessibilityLabel: "Communities starting with a symbol or number",
                communities: communities["other"] ?? .init()
            )
        )
        
        let alphabetics = alphabet.map { character in
            withDependencies(from: self) {
                // This looks sinister but I didn't know how to string replace in a non-string based regex
                return CommunityListSection(
                    viewId: character,
                    sidebarEntry: .init(sidebarLabel: character, sidebarIcon: nil),
                    inlineHeaderLabel: character,
                    accessibilityLabel: "Communities starting with the letter '\(character)'",
                    communities: communities[character, default: .init()]
                )
            }
        }
        ret.append(contentsOf: alphabetics)
        
        return ret
    }
}
