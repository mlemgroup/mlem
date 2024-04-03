//
//  ReplyModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-31.
//

import Foundation

extension ReplyModel: TrackerItem {
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal {
        switch sortType {
        case .new: .new(commentReply.published)
        case .old: .old(commentReply.published)
        }
    }
}
