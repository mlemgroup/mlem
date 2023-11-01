//
//  ReplyModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-31.
//

import Foundation

extension ReplyModel: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(commentReply.published)
        }
    }
}
