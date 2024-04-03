//
//  PostModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Foundation

extension PostModel: TrackerItem {
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal {
        switch sortType {
        case .new: .new(published)
        case .old: .old(published)
        }
    }
}
