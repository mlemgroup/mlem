//
//  TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-15.
//
import Foundation

protocol TrackerItem: Equatable {
    var uid: ContentModelIdentifier { get }
    func sortVal(sortType: TrackerSortVal.Case) -> TrackerSortVal
    
    static func == (lhs: any TrackerItem, rhs: any TrackerItem) -> Bool
}

extension TrackerItem {
    static func == (lhs: any TrackerItem, rhs: any TrackerItem) -> Bool {
        lhs.uid == rhs.uid
    }
}
