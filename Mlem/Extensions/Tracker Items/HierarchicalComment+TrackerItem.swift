//
//  HierarchicalComment+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

extension HierarchicalComment: TrackerItem {
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal {
        switch sortType {
        case .new: .new(commentView.comment.published)
        case .old: .old(commentView.comment.published)
        }
    }
}
