//
//  PostSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-28.
//

import Foundation
import Icons
import MlemMiddleware

extension PostSortType {
    func label(timeRangeFormat: SortTimeRange.FormatStyle = .timescaleFull) -> String {
        switch self {
        case .active:
            .init(localized: "Active")
        case .hot:
            .init(localized: "Hot")
        case .new:
            .init(localized: "New")
        case .old:
            .init(localized: "Old")
        case let .top(timeRange):
            timeRange.label(name: "Top", prefix: "Top:", format: timeRangeFormat)
        case .mostComments:
            .init(localized: "Most Comments")
        case .newComments:
            .init(localized: "New Comments")
        case .controversial:
            .init(localized: "Controversial")
        case .scaled:
            .init(localized: "Scaled")
        }
    }

    var icon: Icon {
        switch self {
        case .active: .lemmy.activeSort
        case .hot: .lemmy.hotSort
        case .new: .lemmy.newSort
        case .old: .lemmy.oldSort
        case .mostComments: .lemmy.mostCommentsSort
        case .newComments: .lemmy.newCommentsSort
        case .controversial: .lemmy.controversialSort
        case .scaled: .lemmy.scaledSort
        case .top: .lemmy.topSort
        }
    }
    
    var explanation: LocalizedStringResource? {
        switch self {
        case .hot: "Ranks posts based on the post score and creation time."
        case .scaled: "Similar to Hot, but ranks posts from smaller communities higher."
        case .active: "Ranks posts based on the post score and the time since the last comment was created."
        default: nil
        }
    }
}
