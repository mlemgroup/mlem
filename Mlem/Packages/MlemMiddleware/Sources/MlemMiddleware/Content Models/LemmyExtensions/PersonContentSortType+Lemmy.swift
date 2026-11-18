//
//  PersonContentSortType+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-08.
//

import Foundation

internal extension PersonContentSortType {
    var v3ApiType: LemmySortType {
        switch self {
        case .new: .new
        case .top: .topAll
        }
    }
}
