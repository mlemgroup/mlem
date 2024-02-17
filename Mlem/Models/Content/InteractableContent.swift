//
//  InteractableContent.swift
//  Mlem
//
//  Created by Sjmarf on 17/02/2024.
//

import Foundation

// Content that can be upvoted, downvoted, saved etc
protocol InteractableContent: AnyObject, ContentStub {
    // These must be implemented
    var creationDate: Date { get }
    var updatedDate: Date? { get }
    var commentCount: Int { get }
    var myVote: ScoringOperation { get }
    var upvoteCount: Int { get }
    var downvoteCount: Int { get }
    var isSaved: Bool { get }
    
    // These don't have to be implemented (are defined as nil in the extension below)
    var unreadCommentCount: Int? { get }
}

extension InteractableContent {
    var unreadCommentCount: Int? { nil }
}

extension InteractableContent {
    var score: Int { upvoteCount - downvoteCount }
}
