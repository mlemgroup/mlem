//
//  HierarchicalComment+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Foundation

extension HierarchicalComment: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published: .published(commentView.comment.published)
        }
    }
}
