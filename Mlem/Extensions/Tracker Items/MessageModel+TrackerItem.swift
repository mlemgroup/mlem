//
//  MessageModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-31.
//

import Foundation

extension MessageModel: TrackerItem {
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(privateMessage.published)
        case .old: .old(privateMessage.published)
        }
    }
}
