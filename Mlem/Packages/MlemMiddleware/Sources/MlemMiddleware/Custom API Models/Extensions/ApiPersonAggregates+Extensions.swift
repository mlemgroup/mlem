//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-22.
//  

import Foundation

extension ApiPersonAggregates {
    static var zero: Self {
        .init(id: nil, personId: 0, postCount: 0, postScore: nil, commentCount: 0, commentScore: nil)
    }
}
