//
//  CommentSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-17.
//

import Foundation
import MlemMiddleware

extension CommentSortType {
    func label(timeRangeFormat: SortTimeRange.FormatStyle = .timescaleFull) -> String {
        switch self {
        case .new:
            .init(localized: "New")
        case .old:
            .init(localized: "Old")
        case .hot:
            .init(localized: "Hot")
        case .controversial:
            .init(localized: "Controversial")
        case let .top(timeRange):
            timeRange.label(prefix: "Top", format: timeRangeFormat)
        }
    }
    
    var systemImage: String {
        switch self {
        case .new: Icons.newSort
        case .old: Icons.oldSort
        case .hot: Icons.hotSort
        case .controversial: Icons.controversialSort
        case .top: Icons.topSort
        }
    }
}
