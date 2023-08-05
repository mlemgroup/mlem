//
//  RecentSearchesTracker.swift
//  Mlem
//
//  Created by Jake Shirley on 7/6/23.
//

import Dependencies
import Foundation

class RecentSearchesTracker: ObservableObject {
    
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    @Published var recentSearches: [String] = .init()
    
    init() {
        recentSearches = persistenceRepository.loadRecentSearches()
    }
    
    func addRecentSearch(_ searchText: String) {
        // don't insert duplicates
        guard !recentSearches.contains(searchText) else {
            return
        }
        
        recentSearches.insert(searchText, at: 0)
        
        // Limit results to 5
        if recentSearches.count > 5 {
            recentSearches = recentSearches.dropLast(1)
        }
        
        persistenceRepository.saveRecentSearches(recentSearches)
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        persistenceRepository.saveRecentSearches(recentSearches)
    }
}
