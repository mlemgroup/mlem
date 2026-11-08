//
//  PersonContentSortType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-08.
//

import Foundation
import Icons
import MlemMiddleware

extension PersonContentSortType {
    var label: LocalizedStringResource {
        switch self {
        case .new: "New"
        case .top: "Top"
        }
    }

    var icon: Icon {
        switch self {
        case .new: .lemmy.newSort
        case .top: .lemmy.topSort
        }
    }
}
