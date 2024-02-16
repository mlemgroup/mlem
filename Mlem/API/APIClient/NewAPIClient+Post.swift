//
//  NewAPIClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

extension NewAPIClient {
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> GetPostsResponse {
        let request = GetPostsRequest(
            communityId: communityId,
            page: page,
            cursor: cursor,
            sort: sort,
            type: .all,
            limit: limit,
            savedOnly: savedOnly
        )
        return try await perform(request: request)
    }
    
    func getPosts(
        feedType: APIListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> GetPostsResponse {
        let request = GetPostsRequest(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: sort,
            type: feedType,
            limit: limit,
            savedOnly: savedOnly
        )
        return try await perform(request: request)
    }
}
