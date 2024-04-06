//
//  MessageReportModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation

extension MessageReportModel: TrackerItem {
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(messageReport.published)
        case .old: .old(messageReport.published)
        }
    }
}
