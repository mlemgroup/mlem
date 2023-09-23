//
//  SearchView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 23/09/2023.
//

import Dependencies
import SwiftUI

class SearchModel: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    
    @Published var searchTab: SearchTab = .topResults
    @Published var searchText: String = ""
    
    // constants
    let pageSize: Int = 20
    
    // Used to switch tabs without refetching from API
    var previousSearchText: String = ""
    var firstPageCommunities: [AnyContentModel]?
    var firstPageUsers: [AnyContentModel]?
    
    func performSearch(page: Int) async throws -> [AnyContentModel] {
        defer { previousSearchText = searchText }
        switch self.searchTab {
        case .topResults:
            async let communities = try await searchCommunities(page: page)
            async let users = try await searchUsers(page: page)
            return try await combineResults(communities: communities, users: users)
        case .communities:
            if searchText != previousSearchText {
                firstPageUsers = nil
            }
            return try await searchCommunities(page: page)
        case .users:
            if searchText != previousSearchText {
                firstPageCommunities = nil
            }
            return try await searchUsers(page: page)
        }
    }
    
    @discardableResult
    func searchCommunities(page: Int) async throws -> [AnyContentModel] {
        let communities = try await apiClient.performSearch(
            query: searchText,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: pageSize
        ).communities.map { AnyContentModel(CommunityModel(from: $0)) }
        if page == 1 {
            self.firstPageCommunities = communities
        }
        return communities
    }
    
    @discardableResult
    func searchUsers(page: Int) async throws -> [AnyContentModel] {
        let users = try await apiClient.performSearch(
            query: searchText,
            searchType: .users,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: pageSize
        ).users.map { AnyContentModel(UserModel(from: $0)) }
        if page == 1 {
            self.firstPageUsers = users
        }
        return users
    }
    
    func combineResults(communities: [AnyContentModel], users: [AnyContentModel]) -> [AnyContentModel] {
        var results: [AnyContentModel] = .init()
        results.append(contentsOf: communities)
        results.append(contentsOf: users)
        return results.sorted { $0.searchResultScore > $1.searchResultScore }
    }
    
}
