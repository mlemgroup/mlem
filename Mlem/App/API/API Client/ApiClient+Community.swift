//
//  NewApiClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

extension ApiClient {
    func getCommunity(id: Int) async throws -> ApiGetCommunityResponse {
        let request = GetCommunityRequest(id: id, name: nil)
        return try await perform(request: request)
    }
    
    func getCommunity(actorId: URL) async throws -> ApiCommunityView? {
        let request = SearchRequest(
            q: actorId.absoluteString,
            communityId: nil,
            communityName: nil,
            creatorId: nil,
            type_: .communities,
            sort: .new,
            listingType: .all,
            page: 1,
            limit: 1
        )
        let response = try await perform(request: request)
        return response.communities.first
    }
}
