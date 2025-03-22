//
//  ApiPostAggregates+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-03.
//

import Foundation

extension ApiPostAggregates: ApiContentAggregatesProtocol {
    static var zero: Self {
        .init(
            id: nil,
            postId: 0,
            comments: 0,
            score: 0,
            upvotes: 0,
            downvotes: 0,
            published: .distantPast,
            newestCommentTimeNecro: nil,
            newestCommentTime: nil,
            featuredCommunity: false,
            featuredLocal: false,
            hotRank: nil,
            hotRankActive: nil
        )
    }
}
