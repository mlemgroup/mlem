//
//  PostReportModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation

extension PostReportModel: TrackerItem {
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(postReport.published)
        case .old: .old(postReport.published)
        }
    }
}
