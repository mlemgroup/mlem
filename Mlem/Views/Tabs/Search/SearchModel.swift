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
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.personRepository) var personRepository
    
    @Published var searchTab: SearchTab = .topResults
    @Published var searchText: String = ""
    
    private var internetSpeed: InternetSpeed
    
    // Used to switch tabs without refetching from API
    var previousSearchText: String = ""
    var firstPageCommunities: [AnyContentModel]?
    var firstPageUsers: [AnyContentModel]?
    
    static var allInstances: [InstanceModel] = []
    
    init(searchTab: SearchTab = .topResults, internetSpeed: InternetSpeed = .fast) {
        self.searchTab = searchTab
        self.internetSpeed = internetSpeed
    }
    
    func tabSwitchRefresh(contentTracker: ContentTracker<AnyContentModel>) {
        switch searchTab {
        case .topResults:
            if let communities = firstPageCommunities, let users = firstPageUsers {
                contentTracker.replaceAll(
                    with: combineResults(
                        communities: communities,
                        users: users,
                        instances: searchInstances(page: 1)
                    )
                )
                return
            }
        case .communities:
            if let communities = firstPageCommunities {
                contentTracker.replaceAll(with: communities)
                return
            }
        case .users:
            if let users = firstPageUsers {
                contentTracker.replaceAll(with: users)
                return
            }
        case .instances:
            contentTracker.replaceAll(with: searchInstances(page: 1))
        }
        contentTracker.refresh(using: performSearch)
    }
    
    func performSearch(page: Int) async throws -> [AnyContentModel] {
        defer { previousSearchText = searchText }
        switch searchTab {
        case .topResults:
            async let communities = try await searchCommunities(page: page)
            async let users = try await searchUsers(page: page)
            async let instances = searchInstances(page: page)
            return try await combineResults(communities: communities, users: users, instances: instances)
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
        case .instances:
            return searchInstances(page: page)
        }
    }
    
    @discardableResult
    func searchCommunities(page: Int) async throws -> [AnyContentModel] {
        let communities = try await communityRepository.search(
            query: searchText,
            page: page,
            limit: internetSpeed.pageSize
        ).map { AnyContentModel($0) }
        if page == 1 {
            firstPageCommunities = communities
        }
        return communities
    }
    
    @discardableResult
    func searchUsers(page: Int) async throws -> [AnyContentModel] {
        let users = try await personRepository.search(
            query: searchText,
            page: page,
            limit: internetSpeed.pageSize
        ).map { AnyContentModel($0) }
        if page == 1 {
            firstPageUsers = users
        }
        return users
    }
    
    @discardableResult
    func searchInstances(page: Int) -> [AnyContentModel] {
        if searchText.isEmpty {
            if page != 1 {
                return []
            }
            return SearchModel.allInstances.map { AnyContentModel($0) }
        }
        
        let query = searchText.lowercased()
        var results: [InstanceModel] = []
        for instance in SearchModel.allInstances {
            if instance.displayName.lowercased().contains(query) || instance.name.contains(query) {
                results.append(instance)
            }
            if results.count == internetSpeed.pageSize {
                break
            }
        }
        let instances = results
            .dropFirst((page - 1) * internetSpeed.pageSize)
            .map { AnyContentModel($0) }
        return instances
    }
    
    func combineResults(
        communities: [AnyContentModel],
        users: [AnyContentModel],
        instances: [AnyContentModel]
    ) -> [AnyContentModel] {
        var results: [AnyContentModel] = .init()
        results.append(contentsOf: communities)
        results.append(contentsOf: users)
        results.append(contentsOf: instances)
        return results.sorted { $0.searchResultScore > $1.searchResultScore }
    }
}
