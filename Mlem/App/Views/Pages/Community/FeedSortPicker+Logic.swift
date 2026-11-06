//
//  FeedSortPicker+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-31.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

extension FeedSortPicker {
    enum Value: Hashable {
        case known(PostSortType)
        case unknown
        
        var sortType: PostSortType? {
            switch self {
            case let .known(postSortType): postSortType
            case .unknown: nil
            }
        }
    }

    var nonTopSortTypes: [PostSortType] {
        PostSortType.nonTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { appState.firstApi.supports(.postSortType($0), defaultValue: true) }
    }
    
    var topSortTypes: [PostSortType] {
        PostSortType.legacyTopCases
            .filter { PinnedSortTracker.main.pinnedSortTypes.contains($0) }
            .filter { appState.firstApi.supports(.postSortType($0), defaultValue: true) }
    }

    var collapseTopSorts: Bool {
        topSortTypes.count > 3 && !nonTopSortTypes.isEmpty
    }

    var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }
}
