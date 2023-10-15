//
//  ChildTrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//

import Foundation

protocol ChildTrackerItemProtocol: TrackerItem {
    associatedtype ParentType: TrackerItem
    
    func toParent() -> ParentType
}
