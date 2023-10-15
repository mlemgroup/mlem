//
//  TrackerSortableNew.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

protocol TrackerSortable {
    func shouldSortBefore(_ other: Self?) -> Bool
}

protocol TrackerItem {
    var uid: ContentModelIdentifier { get }
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal
}
