//
//  Interactable1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

/// Represents a post/comment that you *should* be able to interact with, but you cannot actually interact with due to the model being too low-tier.
public protocol Interactable1Providing: AnyObject, ContentModel, ReportableProviding, ContentIdentifiable {
    var created: Date { get }
    var updated: Date? { get }
    
    var creator_: (any Person)? { get }
    var community_: (any Community)? { get }
    var creatorIsModerator_: Bool? { get }
    var creatorIsAdmin_: Bool? { get }
    var bannedFromCommunity_: Bool? { get }
    var commentCount_: Int? { get }
    var votes_: VotesModel? { get }
    var saved_: Bool? { get }
}
