//
//  Post2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post2Providing: Post1Providing {
    var post2: Post2 { get }
    
    var creator: User1 { get }
    var community: Community1 { get }
    var commentCount: Int { get }
    var upvoteCount: Int { get }
    var downvoteCount: Int { get }
    var unreadCommentsCount: Int { get }
    var isSaved: Bool
    var isRead: Bool
    var myVote: ScoringOperation?
}

extension Post2Providing {
    var post1: Post1 { post2.post1 }
}
