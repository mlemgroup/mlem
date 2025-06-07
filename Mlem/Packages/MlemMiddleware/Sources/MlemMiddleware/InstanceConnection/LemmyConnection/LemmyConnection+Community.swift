//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension LemmyConnection {
    func getCommunity(id: Int) async throws -> Community3Snapshot {
        let response = try await performingForEndpoint { endpoint in
            GetCommunityRequest(endpoint: endpoint, id: id, name: nil)
        }
        return try .init(from: response)
    }
    
    func getCommunity(url: URL) async throws -> Community2Snapshot {
        do {
            let response = try await performingForEndpoint { endpoint in
                ResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
            }
            if let community = response.community {
                return try .init(from: community)
            }
        } catch let ApiClientError.response(response, _) where response.couldntFindObject {
            throw ApiClientError.noEntityFound
        }
        throw ApiClientError.noEntityFound
    }
    
    func getCommunity(url: URL) async throws -> Community3Snapshot {
        let comm: Community2Snapshot = try await getCommunity(url: url)
        return try await getCommunity(id: comm.community.id)
    }
}
