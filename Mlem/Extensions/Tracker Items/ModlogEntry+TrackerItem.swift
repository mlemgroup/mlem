//
//  ModlogEntry+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Foundation

extension ModlogEntry: TrackerItem {
    var uid: ContentModelIdentifier { .init(contentType: .modlog, contentId: hashValue) }
    
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(date)
        case .old: .old(date)
        }
    }
}
