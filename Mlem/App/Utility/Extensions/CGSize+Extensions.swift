//
//  CGSize+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-24.
//

import Foundation

extension CGSize {
    var aspectRatio: Double {
        height / width
    }
    
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    func scaled(by factor: CGFloat) -> CGSize {
        return .init(width: width * factor, height: height * factor)
    }
}
