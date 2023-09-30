//
//  CommunityRepository.swift
//  Mlem
//
//  Created by mormaer on 27/07/2023.
//
//

import Dependencies
import Foundation

struct CommunityRepository {
    @Dependency(\.apiClient) private var apiClient
    
    func search(
        query: String,
        page: Int,
        limit: Int
    ) async throws -> [CommunityModel] {
        let communities = try await apiClient.performSearch(
            query: query,
            searchType: .communities,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: limit
        ).communities.map { CommunityModel(from: $0) }
        return communities
    }
    
    var subscriptions: (APIClient) async throws -> [APICommunityView] = { client in
        let limit = 50
        var page = 1
        var hasMorePages = true
        var communities = [APICommunityView]()
        
        repeat {
            let response = try await client.loadCommunityList(sort: nil, page: page, limit: limit, type: FeedType.subscribed.rawValue)
            communities.append(contentsOf: response.communities)
            hasMorePages = response.communities.count >= limit
            page += 1
        } while hasMorePages
        
        return communities
    }
    
    var details: (APIClient, Int) async throws -> GetCommunityResponse = { client, id in
        try await client.loadCommunityDetails(id: id)
    }
    
    var updateSubscription: (APIClient, Int, Bool) async throws -> APICommunityView = { client, id, subscribed in
        try await client.followCommunity(id: id, shouldFollow: subscribed)
            .communityView
    }
    
    var hideCommunity: (APIClient, Int, String?) async throws -> CommunityResponse = { client, id, reason in
        try await client.hideCommunity(id: id, shouldHide: true, reason: reason)
    }
    
    var unhideCommunity: (APIClient, Int) async throws -> CommunityResponse = { client, id in
        try await client.hideCommunity(id: id, shouldHide: false, reason: nil)
    }
    
    var blockCommunity: (APIClient, Int) async throws -> BlockCommunityResponse = { client, id in
        try await client.blockCommunity(id: id, shouldBlock: true)
    }
    
    var unblockCommunity: (APIClient, Int) async throws -> BlockCommunityResponse = { client, id in
        try await client.blockCommunity(id: id, shouldBlock: false)
    }
    
    func loadSubscriptions() async throws -> [APICommunityView] {
        try await subscriptions(apiClient)
    }
    
    func loadDetails(for id: Int) async throws -> GetCommunityResponse {
        try await details(apiClient, id)
    }
    
    func loadDetails(for id: Int) async throws -> CommunityModel {
        CommunityModel(from: try await details(apiClient, id).communityView)
    }
    
    @discardableResult
    func updateSubscription(for communityId: Int, subscribed: Bool) async throws -> APICommunityView {
        try await updateSubscription(apiClient, communityId, subscribed)
    }
    
    func hideCommunity(id: Int, reason: String? = nil) async throws -> CommunityResponse {
        try await hideCommunity(apiClient, id, reason)
    }
    
    func unhideCommunity(id: Int) async throws -> CommunityResponse {
        try await unhideCommunity(apiClient, id)
    }
    
    @discardableResult
    func blockCommunity(id: Int) async throws -> BlockCommunityResponse {
        try await blockCommunity(apiClient, id)
    }
    
    @discardableResult
    func unblockCommunity(id: Int) async throws -> BlockCommunityResponse {
        try await unblockCommunity(apiClient, id)
    }
}
