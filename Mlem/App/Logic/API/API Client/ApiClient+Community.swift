//
//  NewApiClient+Requests.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

extension ApiClient {
    func getCommunity(id: Int) async throws -> Community3 {
        let request = GetCommunityRequest(id: id, name: nil)
        let response = try await perform(request)
        return caches.community3.getModel(api: self, from: response)
    }
    
    func getCommunity(actorId: URL) async throws -> Community3? {
        // search for community
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
        
        // if community found, get as Community3--caching performed in call
        if let response = try await perform(request).communities.first {
            return try await getCommunity(id: response.id)
        }
        return nil
    }
}
