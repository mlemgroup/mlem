//
//  Post2.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

@Observable
final class Post2: Post2Providing, ContentModel {
    typealias ApiType = ApiPostView
    var post2: Post2 { self }
    
    var api: ApiClient
    
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
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
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
    
    func update(with post: ApiPostView) {
        commentCount = post.counts.comments
        upvoteCount = post.counts.upvotes
        downvoteCount = post.counts.downvotes
        unreadCommentCount = post.unreadComments
        isSaved = post.saved
        isRead = post.read
        myVote = ScoringOperation.guaranteedInit(from: post.myVote)
        
        post1.update(with: post.post)
        creator.update(with: post.creator)
        community.update(with: post.community)
        
        creator.blocked = post.creatorBlocked
    }
    
    var score: Int { upvoteCount - downvoteCount }
}
