//
//  PersonContentSortType+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-11-08.
//

import Foundation

public extension PersonContentSortType {
    var pieFedSortType: PieFedSortType {
        switch self {
        case .new: .new
        case .top: .topAll
        }
    }
}
