//
//  MentionModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-31.
//

import Foundation

extension MentionModel: TrackerItem {
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(personMention.published)
        case .old: .old(personMention.published)
        }
    }
}
