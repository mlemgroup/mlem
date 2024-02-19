//
//  Post2.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

@Observable
final class Post2: Post2Providing, NewContentModel {
    typealias APIType = APIPostView
    var post2: Post2 { self }
    
    var source: any APISource
    
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
    
    init(source: any APISource, from post: APIPostView) {
        self.source = source
        
        self.post1 = source.caches.post1.createModel(source: source, for: post.post)
        self.creator = source.caches.person1.createModel(source: source, for: post.creator)
        self.community = source.caches.community1.createModel(source: source, for: post.community)
        update(with: post)
    }
    
    func update(with post: APIPostView) {
        commentCount = post.counts.comments
        upvoteCount = post.counts.upvotes
        downvoteCount = post.counts.downvotes
        unreadCommentCount = post.unread_comments
        isSaved = post.saved
        isRead = post.read
        myVote = .init(rawValue: post.my_vote ?? 0) ?? .none // TODO: this can be nicer
        
        post1.update(with: post.post)
        creator.update(with: post.creator)
        community.update(with: post.community)
        
        creator.blocked = post.creator_blocked
    }
    
    var score: Int { upvoteCount - downvoteCount }
}
