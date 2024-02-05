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
    func reloadRecentSearches(accountId: String?, instances: [InstanceModel]) async throws {
        defer { hasLoaded = true }
        
        if let accountId {
            let identifiers = persistenceRepository.loadRecentSearches(for: accountId)
            var newSearches: [AnyContentModel] = .init()
            
            for id in identifiers {
                switch id.contentType {
                case .post:
                    break
                case .community:
                    let community: CommunityModel = try await communityRepository.loadDetails(for: id.contentId)
                    newSearches.append(AnyContentModel(community))
                case .user:
                    let user = try await personRepository.loadUser(for: id.contentId)
                    newSearches.append(AnyContentModel(user))
                case .instance:
                    if let instance = instances.first(where: { $0.name.hash == id.contentId }) {
                        newSearches.append(AnyContentModel(instance))
                    } else {
                        print("Recent search error: cannot find instance sub")
                    }
                default:
                    assertionFailure("Received unexpected content type in recent searches \(id.contentType)")
                    return
                }
            }
            
            recentSearches = newSearches
        }
    }
    
    func addRecentSearch(_ item: AnyContentModel, accountId: String?) {
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
        saveRecentSearches(accountId: accountId)
    }
    
    func removeRecentSearch(_ item: AnyContentModel, accountId: String?) {
        if let index = recentSearches.firstIndex(of: item) {
            recentSearches.remove(at: index)
        }
        saveRecentSearches(accountId: accountId)
    }
    
    func clearRecentSearches(accountId: String?) {
        recentSearches.removeAll()
        saveRecentSearches(accountId: accountId)
    }
    
    private func saveRecentSearches(accountId: String?) {
        if let accountId {
            print("saving searches for \(accountId)")
            Task(priority: .background) {
                try await persistenceRepository.saveRecentSearches(for: accountId, with: recentSearches.map(\.uid))
            }
        }
    }
}
