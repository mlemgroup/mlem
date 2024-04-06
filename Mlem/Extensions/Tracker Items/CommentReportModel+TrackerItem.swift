//
//  CommentReportModel+TrackerItem.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation

extension CommentReportModel: TrackerItem {
    func sortVal(sortType: TrackerSort.Case) -> TrackerSort {
        switch sortType {
        case .new: .new(commentReport.published)
        case .old: .old(commentReport.published)
        }
    }
}
