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
    var votes: VotesModel { get }
    var isSaved: Bool { get }
}
