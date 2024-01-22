//
//  UserContentTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-22.
//

import Foundation

enum UserContentItem: TrackerItem {
    case post(PostModel)
    case comment(CommentModel)
    
    var uid: ContentModelIdentifier {
        switch self {
        case let .post(postModel): postModel.uid
        case let .comment(commentModel): commentModel.uid
        }
    }
    
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch self {
        case let .post(postModel): postModel.sortVal(sortType: sortType)
        case let .comment(commentModel): commentModel.sortVal(sortType: sortType)
        }
    }
}
