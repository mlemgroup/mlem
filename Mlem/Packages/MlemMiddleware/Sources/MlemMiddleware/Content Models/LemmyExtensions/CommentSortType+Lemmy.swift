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
    
    var v3CommentApiType: LemmyCommentSortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .top
        }
    }
    
    var v3PostApiType: LemmySortType {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: .controversial
        case .top: .topAll
        }
    }
}
