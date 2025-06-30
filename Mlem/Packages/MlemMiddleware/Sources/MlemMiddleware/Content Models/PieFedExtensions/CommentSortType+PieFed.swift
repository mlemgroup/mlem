//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension CommentSortType {
    var piefedSortType: PieFedCommentSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .hot: .hot
        case .controversial: nil
        case .top(.allTime): .top
        case .top: nil
        }
    }
}
