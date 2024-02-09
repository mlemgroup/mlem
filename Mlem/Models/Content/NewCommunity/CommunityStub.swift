//
//  CommunityStub.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import SwiftUI

protocol CommunityStubProviding {
    var communityId: Int { get }
}

struct CommunityStub: CommunityStubProviding {
    let communityId: Int
}

extension CommunityStubProviding {
    func loadPosts(page: Int) -> [Int] {
        return [1, 2, 3]
    }
    
    func upgrade() async throws -> CommunityTier3 {
        @Dependency(\.apiClient) var apiClient
        let response = try await apiClient.loadCommunityDetails(id: communityId)
        return CommunityTier3.cache.createModel(for: response)
    }
}
