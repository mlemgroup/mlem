//
//  SearchSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-01.
//

import Foundation
import MlemMiddleware

extension SearchSortType {
    func label(timeRangeFormat: SortTimeRange.FormatStyle = .timescaleFull) -> String {
        switch self {
        case .new:
            .init(localized: "New")
        case .old:
            .init(localized: "Old")
        case let .top(timeRange):
            timeRange.label(name: "Top", prefix: "Top:", format: timeRangeFormat)
        }
    }
    
    var systemImage: String {
        switch self {
        case .new: Icons.newSort
        case .old: Icons.oldSort
        case .top: Icons.topSort
        }
    }
}
