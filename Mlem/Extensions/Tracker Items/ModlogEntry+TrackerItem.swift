//
//  ModlogEntry+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Foundation

extension ModlogEntry: TrackerItem {
    var uid: ContentModelIdentifier { .init(contentType: .modlog, contentId: hashValue) }
    
    func sortVal(sortType: TrackerSortType) -> TrackerSortVal {
        switch sortType {
        case .published:
            return .published(date)
        }
    }
}
