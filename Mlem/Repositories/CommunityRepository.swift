// 
//  CommunityRepository.swift
//  Mlem
//
//  Created by mormaer on 27/07/2023.
//  
//

import Dependencies
import Foundation

class CommunityRepository {
    
    @Dependency(\.apiClient) private var apiClient
    
    // MARK: - Public methods
    
    func loadSubscriptions() async throws -> [APICommunityView] {
        let limit = 50
        var page = 1
        var hasMorePages = true
        var communities = [APICommunityView]()
        
        repeat {
            let response = try await loadCommunityList(page: page, limit: limit, type: .subscribed)
            communities.append(contentsOf: response.communities)
            hasMorePages = response.communities.count >= limit
            page += 1
        } while hasMorePages
        
        return communities
    }
    
    func loadDetails(for id: Int) async throws -> GetCommunityResponse {
        try await apiClient.loadCommunityDetails(id: id)
    }
    
    @discardableResult
    func updateSubscription(for communityId: Int, subscribed: Bool) async throws -> APICommunityView {
        try await apiClient.followCommunity(id: communityId, shouldFollow: subscribed)
            .communityView
    }
    
    func hideCommunity(id: Int, reason: String? = nil) async throws -> CommunityResponse {
        try await apiClient.hideCommunity(id: id, shouldHide: true, reason: reason)
    }
    
    func unhideCommunity(id: Int) async throws -> CommunityResponse {
        try await apiClient.hideCommunity(id: id, shouldHide: false, reason: nil)
    }
    
    @discardableResult
    func blockCommunity(id: Int) async throws -> BlockCommunityResponse {
        try await apiClient.blockCommunity(id: id, shouldBlock: true)
    }
    
    @discardableResult
    func unblockCommunity(id: Int) async throws -> BlockCommunityResponse {
        try await apiClient.blockCommunity(id: id, shouldBlock: false)
    }
    
    // MARK: - Private methods
    
    private func loadCommunityList(page: Int, limit: Int, type: FeedType) async throws -> ListCommunityResponse {
        try await apiClient.loadCommunityList(sort: nil, page: page, limit: limit, type: type.rawValue)
    }
}
