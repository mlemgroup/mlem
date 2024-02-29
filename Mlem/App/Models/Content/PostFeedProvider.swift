//
//  PostFeedProvider.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-28.
//

import Foundation

protocol PostFeedProvider: ActorIdentifiable {
    // swiftlint:disable:next function_parameter_count
    func getPosts(
        feed: ApiListingType,
        sort: ApiSortType,
        page: Int,
        cursor: String?,
        limit: Int,
        savedOnly: Bool
    ) async throws -> (posts: [Post2], cursor: String?)
}
