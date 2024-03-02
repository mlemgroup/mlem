//
//  Post2.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

@Observable
final class Post2: Post2Providing {
    var api: ApiClient
    var post2: Post2 { self }
    
    let post1: Post1
    
    let creator: Person1
    let community: Community1
    
    var commentCount: Int = 0
    var upvoteCount: Int = 0
    var downvoteCount: Int = 0
    var unreadCommentCount: Int = 0
    var isSaved: Bool = false
    var isRead: Bool = false
    var myVote: ScoringOperation = .none
    var score: Int { upvoteCount - downvoteCount }
    
    init(
        api: ApiClient,
        post1: Post1,
        creator: Person1,
        community: Community1,
        commentCount: Int = 0,
        upvoteCount: Int = 0,
        downvoteCount: Int = 0,
        unreadCommentCount: Int = 0,
        isSaved: Bool = false,
        isRead: Bool = false,
        myVote: ScoringOperation = .none
    ) {
        self.api = api
        self.post1 = post1
        self.creator = creator
        self.community = community
        self.commentCount = commentCount
        self.upvoteCount = upvoteCount
        self.downvoteCount = downvoteCount
        self.unreadCommentCount = unreadCommentCount
        self.isSaved = isSaved
        self.isRead = isRead
        self.myVote = myVote
    }
}
