//
//  UserContentModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

extension UserContentModel: TrackerItem {
    static func == (lhs: UserContentModel, rhs: UserContentModel) -> Bool {
        lhs.uid == rhs.uid
    }
    
    var uid: ContentModelIdentifier {
        switch self {
        case let .post(postModel): postModel.uid
        case let .comment(hierarchicalComment): hierarchicalComment.uid
        }
    }
    
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch self {
        case let .post(postModel): postModel.sortVal(sortType: sortType)
        case let .comment(hierarchicalComment): hierarchicalComment.sortVal(sortType: sortType)
        }
    }
}
