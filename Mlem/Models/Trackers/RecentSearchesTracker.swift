//
//  RecentSearchesTracker.swift
//  Mlem
//
//  Created by Jake Shirley on 7/6/23.
//

import Dependencies
import Foundation

@MainActor
class RecentSearchesTracker: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.apiClient) var apiClient
    
    var hasLoaded: Bool = false
    @Published var recentSearches: [AnyContentModel] = .init()
    
    /// clears recentSearches and loads new values based on the current account
    func reloadRecentSearches(accountHash: Int?) async throws {
        defer { hasLoaded = true }
        
        recentSearches = .init()
        if let accountHash {
            let identifiers = persistenceRepository.loadRecentSearches(for: accountHash)
            
            for id in identifiers {
                print(id.contentType, id.contentId)
                switch id.contentType {
                case .post:
                    break
                case .community:
                    let community: CommunityModel = try await communityRepository.loadDetails(for: id.contentId)
                    recentSearches.append(AnyContentModel(community))
                case .user:
                    let user = try await personRepository.loadDetails(for: id.contentId)
                    recentSearches.append(AnyContentModel(user))
                }
            }
        }
    }
    
    func addRecentSearch(_ item: AnyContentModel, accountHash: Int?) {
        // if the item is already in the recent list, move it to the top
        if let index = recentSearches.firstIndex(of: item) {
            recentSearches.remove(at: index)
            recentSearches.insert(item, at: 0)
        } else {
            recentSearches.insert(item, at: 0)
            
            // Limit results to 10
            if recentSearches.count > 10 {
                recentSearches = recentSearches.dropLast(1)
            }
        }
        saveRecentSearches(accountHash: accountHash)
    }
    
    func clearRecentSearches(accountHash: Int?) {
        recentSearches.removeAll()
        saveRecentSearches(accountHash: accountHash)
    }
    
    private func saveRecentSearches(accountHash: Int?) {
        if let accountHash {
            Task(priority: .background) {
                try await persistenceRepository.saveRecentSearches(for: accountHash, with: recentSearches.map(\.uid))
            }
        }
    }
}
