//
//  PostModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Foundation

extension PostModel: TrackerItem {
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(published)
        }
    }
}
