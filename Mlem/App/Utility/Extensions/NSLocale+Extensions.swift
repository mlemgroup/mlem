//
//  NSLocale+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-07-12.
//

import Foundation
import SwiftUI

extension NSLocale.LanguageDirection {
    var layoutDirection: LayoutDirection {
        switch self {
        case .unknown, .leftToRight, .topToBottom, .bottomToTop:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        default:
            assertionFailure("Unrecognized NSLocale.LayoutDirection!")
            return .leftToRight
        }
    }
}
