//
//  ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

protocol ChildTrackerItem: TrackerItem {
    associatedtype ParentType: TrackerItem
    
    func toParent() -> ParentType
}
