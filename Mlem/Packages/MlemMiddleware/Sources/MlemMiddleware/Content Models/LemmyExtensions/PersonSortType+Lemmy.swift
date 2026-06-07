//
//  PersonSortType+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

// MARK:- v3

extension PersonSortType {
    // Source code for the conversions on Lemmy's side:
    // https://github.com/LemmyNet/lemmy/blob/1846ae9e19e7a2d8eb275c3f6406770a552f5647/crates/db_views_actor/src/person_view.rs#L108

    internal var v3ApiType: LemmySortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .commentCount: .topAll
        case .postScore, .commentScore, .postCount: nil
        }
    }
}

// MARK:- v4

extension PersonSortType {
    internal var v4ApiType: LemmyPersonSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .commentScore: .commentScore
        case .postScore: .postScore
        case .commentCount, .postCount: nil
        }
    }
}
