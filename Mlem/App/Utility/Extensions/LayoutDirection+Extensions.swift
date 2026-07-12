//
//  LayoutDirection+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-07-12.
//

import SwiftUI

extension LayoutDirection {
    var inverted: LayoutDirection {
        switch self {
        case .leftToRight:
            return .rightToLeft
        case .rightToLeft:
            return .leftToRight
        default:
            assertionFailure("Unknown LayoutDirection!")
            return .leftToRight
        }
    }
}
