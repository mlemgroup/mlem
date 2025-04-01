//
//  CGPoint+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

import Foundation

extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
