//
//  NewAPIClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

extension NewAPIClient {
    func getCommunity(id: Int) async throws -> GetCommunityResponse {
        let request = GetCommunityRequest(communityId: id)
        return try await perform(request: request)
    }
    
    func getCommunity(actorId: URL) async throws -> APICommunityView? {
        let request = SearchRequest(query: actorId.absoluteString, searchType: .communities, sortOption: .new, listingType: .all, page: 1, communityId: nil, communityName: nil, creatorId: nil, limit: 1)
        let response = try await perform(request: request)
        return response.communities.first
    }
}