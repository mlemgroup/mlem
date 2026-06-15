//
//  PersonSortType+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation

public extension PersonSortType {
    // Source code for the conversions on PieFed's side:
    // https://codeberg.org/rimu/pyfedi/src/commit/d04a3ff48121fbf221404dcfacf52852ced1ad3b/app/api/alpha/utils/user.py#L105

    var pieFedSearchSortType: PieFedSearchSortType? {
        switch self {
        case .new: .new
        case .old: .old
        case .postCount: .top
        case .commentCount, .postScore, .commentScore: nil
        }
    }
}
