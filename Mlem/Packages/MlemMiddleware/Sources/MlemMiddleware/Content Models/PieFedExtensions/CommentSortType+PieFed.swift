//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension CommentSortType {
    var piefedSearchSortType: PieFedSearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: nil
        case .top(.allTime): .top
        case .top: nil
        }
    }

    var piefedSortType: PieFedSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: nil
        case .top(.allTime): .top
        case .top: nil
        }
    }

    // Controversial is not supported
    // https://codeberg.org/rimu/pyfedi/src/commit/d04a3ff48121fbf221404dcfacf52852ced1ad3b/app/api/alpha/utils/reply.py#L206

    var piefedCommentSortType: PieFedCommentSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .top(.allTime): .top
        case .top, .controversial: nil
        }
    }
}
