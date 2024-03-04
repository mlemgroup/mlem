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
        let urlString = actorId.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let request = ResolveObjectRequest(q: urlString ?? actorId.absoluteString)
        let response = try await perform(request: request)
        return response.community
    }
}
