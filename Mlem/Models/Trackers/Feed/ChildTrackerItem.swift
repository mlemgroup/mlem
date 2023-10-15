//
//  ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-14.
//

import Foundation

protocol ChildTrackerItem: ContentIdentifiable {
    associatedtype ParentItem: ParentTrackerItem
    
    func toParentItem() -> ParentItem
    func getSortVal(sortType: ParentItem.SortType) -> ParentItem.SortVal
}
