//
//  NewAPIClient+Post.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

extension APIClient {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        communityId: Int,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> APIGetPostsResponse {
        let request = APIGetPostsRequest(
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
    
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feedType: APIListingType,
        sort: PostSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> APIGetPostsResponse {
        print("REQUEST", feedType, sort, endpointUrl, token)
        let request = GetPostsRequest(
            communityId: nil,
            page: page,
            cursor: cursor,
            sort: sort,
            type: feedType,
            limit: limit,
            savedOnly: savedOnly
        )
        let response = try await perform(request: request)
        print("RESPONSE", response.posts.first?.post.name)
        return response
    }
}
