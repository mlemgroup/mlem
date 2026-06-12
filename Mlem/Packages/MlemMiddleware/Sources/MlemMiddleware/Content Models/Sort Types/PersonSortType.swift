//
//  PersonSortType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public enum PersonSortType: Hashable, Sendable, CaseIterable {
    case new
    case old
    case postCount
    case commentCount
    case postScore

    // Lemmy v3 supports time ranges for commentScore, but v4 does not.
    // Not bothering to implement time ranges.
    case commentScore
}
