//
//  Community Sort Type Tracker.swift
//  Mlem
//
//  Created by Jake Shirley on 8/10/23.
//

import Foundation
import Dependencies
import SwiftUI

// Tracks, stores, and saves the post sort type
// for feeds
@MainActor
class FeedSortTypeTracker: ObservableObject {
    
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published private var sortTypes: [String: PostSortType] = .init()
    
    init() {
        sortTypes = persistenceRepository.loadFeedSortingPreferences()
    }
    
    var isEmpty: Bool {
        return sortTypes.isEmpty
    }
    
    var count: Int {
        return sortTypes.count
    }
    
    func clear() {
        sortTypes.removeAll()
        saveSortTypes()
    }
    
    func saveSortTypes() {
        Task {
            try await persistenceRepository.saveFeedSortingPreferences(sortTypes)
        }
    }
    
    func getSortType(for community: APICommunity) -> PostSortType {
        if let communityKey = getKey(for: community) {
            if let configuredSortType = sortTypes[communityKey] {
                return configuredSortType
            }
        }
        return defaultPostSorting
    }
    
    // Returns the default if the value has not been set
    // explicitly by the user
    func getSortType(for feedType: FeedType) -> PostSortType {
        if let configuredSortType = sortTypes[getKey(for: feedType)] {
            return configuredSortType
        }
        return defaultPostSorting
    }
    
    func setSortType(for community: APICommunity, sortType: PostSortType) {
        if let communityKey = getKey(for: community) {
            print("Setting sort type for '\(communityKey)' to '\(sortType.description)'")
            sortTypes[communityKey] = sortType
            
            saveSortTypes()
        }
    }
    
    func setSortType(for feedType: FeedType, sortType: PostSortType) {
        let dictKey = getKey(for: feedType)
        print("Setting sort type for '\(dictKey)' to '\(sortType.description)'")
        sortTypes[dictKey] = sortType
        
        saveSortTypes()
    }
    
    private func getKey(for community: APICommunity) -> String? {
        if let serverHost = community.actorId.host() {
            return "\(community.name.lowercased())@\(serverHost.lowercased())"
        }
        return nil
    }
    
    private func getKey(for feedType: FeedType) -> String {
        return "feed \(feedType.rawValue.lowercased())"
    }
}
