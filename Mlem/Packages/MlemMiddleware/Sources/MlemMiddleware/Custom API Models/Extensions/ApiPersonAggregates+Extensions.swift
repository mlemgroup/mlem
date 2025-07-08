//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//

import Foundation

extension LemmyPersonAggregates {
    static var zero: Self {
        .init(personId: 0, postCount: 0, commentCount: 0)
    }
}
