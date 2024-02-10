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
}
