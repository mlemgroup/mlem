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
    
    func loadRecentSearches() async throws {
        hasLoaded = true
        let identifiers = persistenceRepository.loadRecentSearches()
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
    
    func addRecentSearch(_ item: AnyContentModel) {
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
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
    
    private func saveRecentSearches() {
        Task(priority: .background) {
            try await persistenceRepository.saveRecentSearches(recentSearches.map { $0.uid })
        }
    }
}
