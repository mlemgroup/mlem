//
//  CommentSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-17.
//

import Foundation
import Icons
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
            timeRange.label(name: "Top", prefix: "Top:", format: timeRangeFormat)
        }
    }
    
    var icon: Icon {
        switch self {
        case .new: .lemmy.newSort
        case .old: .lemmy.oldSort
        case .hot: .lemmy.hotSort
        case .controversial: .lemmy.controversialSort
        case .top: .lemmy.topSort
        }
    }
}
