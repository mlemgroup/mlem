//
//  SearchModel.swift
//  Mlem
//
//  Created by Sjmarf on 26/08/2023.
//

import SwiftUI
import Dependencies

class SearchModel: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    
    @Published private(set) var input: String = ""
    
    @Published private(set) var communities: [APICommunityView] = .init()
    @Published private(set) var users: [APIPersonView] = .init()
    
    @Published private(set) var showSubscribedTokenSuggestion: Bool = false
    @Published private(set) var communityTokenSuggestions: [APICommunityView] = .init()
    
    @MainActor
    func fetchResults(_ input: String) async throws {
        let lowercasedInput = input.lowercased()
        
        showSubscribedTokenSuggestion = "subscribed".hasPrefix(lowercasedInput)
        
        try await fetchCommunities(lowercasedInput)
        try await fetchUsers(lowercasedInput)
        
        // We set this last so that the highlighted text updates at the same time as the results
        self.input = lowercasedInput
    }
    
    @MainActor
    func fetchCommunities(_ input: String) async throws {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: 1,
            limit: 5
        )
        communities = response.communities
        
        communityTokenSuggestions.removeAll()
        var subscriberLimit: Int?
        
        for community in communities where community.community.name.lowercased().hasPrefix(input) {
            if let first = communityTokenSuggestions.first {
                if first.community.name == community.community.name && community.counts.subscribers > subscriberLimit! {
                    communityTokenSuggestions.append(community)
                }
            } else {
                communityTokenSuggestions.append(community)
                subscriberLimit = Int(Float(community.counts.subscribers) * 0.1)
            }
        }
    }
        
    @MainActor
    func fetchUsers(_ input: String) async throws {
        let response = try await apiClient.performSearch(
            query: input,
            searchType: .users,
            sortOption: .topAll,
            listingType: .all,
            page: 1,
            limit: 3
        )
        users = response.users
    }
}
