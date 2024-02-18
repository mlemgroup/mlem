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
    var myVote: ScoringOperation { get set }
    var upvoteCount: Int { get set }
    var downvoteCount: Int { get set }
    var isSaved: Bool { get set }
    
    func vote(_: ScoringOperation) async throws
    
    func toggleSave() async throws
}

extension InteractableContent {
    var score: Int { upvoteCount - downvoteCount }
    
    func toggleUpvote() async throws {
        try await vote(myVote == .upvote ? .none : .upvote)
    }
    
    func toggleDownvote() async throws {
        try await vote(myVote == .downvote ? .none : .downvote)
    }
}
