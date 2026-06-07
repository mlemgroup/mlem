//
//  ActiveUserTimeRange+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation
import Icons
import MlemMiddleware

extension ActiveUserTimeRange {
    var label: String {
        let sortTimeRange: SortTimeRange = switch self {
        case .day: .limited(.day)
        case .week: .limited(.week)
        case .month: .limited(.month)
        case .sixMonths: .limited(.sixMonth)
        }

        return sortTimeRange.label(abbreviateUnits: false)
    }
}
