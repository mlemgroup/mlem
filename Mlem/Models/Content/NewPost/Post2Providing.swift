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
    var isSaved: Bool { get }
    var isRead: Bool { get }
    var myVote: ScoringOperation { get }
}

extension Post2Providing {
    var post1: Post1 { post2.post1 }
    
    var creator: User1 { post2.creator }
    var community: Community1 { post2.community }
    var commentCount: Int { post2.commentCount }
    var upvoteCount: Int { post2.upvoteCount }
    var downvoteCount: Int { post2.downvoteCount }
    var unreadCommentsCount: Int { post2.unreadCommentsCount }
    var isSaved: Bool { post2.isSaved }
    var isRead: Bool { post2.isRead }
    var myVote: ScoringOperation { post2.myVote }
}
