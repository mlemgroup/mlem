//
//  PersonSortType+Extensions.swift<Extensions>
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation
import Icons
import MlemMiddleware

extension PersonSortType {
    var label: LocalizedStringResource {
        switch self {
        case .new: "New"
        case .old: "Old"
        case .postCount: "Posts"
        case .commentCount: "Comments"
        case .postScore: "Post Votes"
        case .commentScore: "Comment Votes"
        }
    }
    
    var icon: Icon {
        switch self {
        case .new: .lemmy.newSort
        case .old: .lemmy.oldSort
        case .postCount: .lemmy.post
        case .commentCount: .lemmy.comment
        case .postScore, .commentScore: .lemmy.upvoted
        }
    }
}
