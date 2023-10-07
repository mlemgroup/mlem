//
//  APIClient+Community.swift
//  Mlem
//
//  Created by mormaer on 26/07/2023.
//
//

import Foundation

extension APIClient {
    func loadCommunityList(
        sort: String?,
        page: Int?,
        limit: Int?,
        type: String
    ) async throws -> ListCommunityResponse {
        let request = try ListCommunitiesRequest(
            session: session,
            sort: sort,
            page: page,
            limit: limit,
            type: type
        )
        
        return try await perform(request: request)
    }
    
    func loadCommunityDetails(id: Int) async throws -> GetCommunityResponse {
        let request = try GetCommunityRequest(session: session, communityId: id)
        return try await perform(request: request)
    }
    
    func followCommunity(id: Int, shouldFollow: Bool) async throws -> CommunityResponse {
        let request = try FollowCommunityRequest(session: session, communityId: id, follow: shouldFollow)
        return try await perform(request: request)
    }
    
    func hideCommunity(id: Int, shouldHide: Bool, reason: String?) async throws -> CommunityResponse {
        let request = try HideCommunityRequest(
            session: session,
            communityId: id,
            hidden: shouldHide,
            reason: reason
        )
        
        return try await perform(request: request)
    }
    
    func blockCommunity(id: Int, shouldBlock: Bool) async throws -> BlockCommunityResponse {
        let request = try BlockCommunityRequest(
            session: session,
            communityId: id,
            block: shouldBlock
        )
        
        return try await perform(request: request)
    }
}
