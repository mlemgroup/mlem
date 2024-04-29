//
//  Interactable1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation
import MlemMiddleware

/// Represents a post/comment that you *should* be able to interact with, but you cannot actually interact with due to the model being too low-tier.
protocol Interactable1Providing: AnyObject, Actionable, ContentStub {
    var created: Date { get }
    var updated: Date? { get }
    
    var upvoteAction: BasicAction { get }
    var downvoteAction: BasicAction { get }
    var saveAction: BasicAction { get }
}
