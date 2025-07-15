//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

// This is reluncantly public because Mlem uses it; this should really be `internal`
public extension CommentSortType {
    init(_ apiSortType: LemmyCommentSortType) {
        self = switch apiSortType {
        case .hot: .hot
        case .top: .top(.allTime)
        case .new: .new
        case .old: .old
        case .controversial: .controversial
        }
    }
    
    var apiSortType: LemmyCommentSortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .top
        }
    }
    
    var legacyApiSortType: LemmySortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .topAll
        }
    }
    
    /// Returns `nil` if the `CommentSortType` is a value that cannot be converted to an `LemmySearchSortType`.
    var apiSearchSortType: LemmySearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .top: .top
        default: nil
        }
    }
}
