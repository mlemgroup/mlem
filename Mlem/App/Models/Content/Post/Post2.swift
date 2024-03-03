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
    
    var votes: VotesModel
    var commentCount: Int
    var unreadCommentCount: Int
    var isSaved: Bool
    var isRead: Bool
    
    var voteStatusManager: VoteStatusManager = .init()
    
    var tasks: Tasks = .init()
    
    struct Tasks {
        // var vote: Task<Void, Never>?
        var save: Task<Void, Never>?
    }
    
    init(
        api: ApiClient,
        post1: Post1,
        creator: Person1,
        community: Community1,
        votes: VotesModel,
        commentCount: Int = 0,
        unreadCommentCount: Int = 0,
        isSaved: Bool = false,
        isRead: Bool = false
    ) {
        self.api = api
        self.post1 = post1
        self.creator = creator
        self.community = community
        self.votes = votes
        self.commentCount = commentCount
        self.unreadCommentCount = unreadCommentCount
        self.isSaved = isSaved
        self.isRead = isRead
    }
}
