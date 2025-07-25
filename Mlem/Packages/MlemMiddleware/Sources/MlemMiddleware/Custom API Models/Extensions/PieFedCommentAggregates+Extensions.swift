//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-25.
//

import Foundation

extension PieFedCommentAggregates: ApiContentAggregatesProtocol {
    public var comments: Int { childCount }
    
    static var zero: Self {
        .init(commentId: 0, score: 0, upvotes: 0, downvotes: 0, published: .distantPast, childCount: 0)
    }
}
