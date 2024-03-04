//
//  APIPersonAggregates+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Foundation

extension APIPersonAggregates {
    static func mock(
        personId: Int = 0,
        postCount: Int = 5,
        commentCount: Int = 20
    ) -> APIPersonAggregates {
        .init(
            id: nil,
            personId: personId,
            postCount: postCount,
            postScore: nil,
            commentCount: commentCount,
            commentScore: nil
        )
    }
}
