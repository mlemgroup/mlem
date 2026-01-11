//
//  CommentStubProviding.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation

public protocol CommentStubProviding: ContentModel, Resolvable {
    // From Comment1Providing. These are defined as nil in the extension below
    var actorId_: ActorIdentifier? { get }
    var content_: String? { get }
    var created_: Date? { get }
    var updated_: Date? { get }
    var deleted_: Bool? { get }
    var creatorId_: Int? { get }
    var postId_: Int? { get }
    var parentCommentIds_: [Int]? { get }
    var distinguished_: Bool? { get }
    var removed_: Bool? { get }
    var removedManager_: StateManager<Bool>? { get }
    var languageId_: Int? { get }
    
    // From Comment2Providing. These are defined as nil in the extension below
    var creator_: (any Person)? { get }
    var post_: UnifiedPostModel? { get }
    var community_: (any Community)? { get }
    var votes_: VotesModel? { get }
    var saved_: Bool? { get }
    var creatorIsModerator_: Bool? { get }
    var creatorIsAdmin_: Bool? { get }
    var creatorBannedFromCommunity_: Bool? { get }
    var commentCount_: Int? { get }
    
    func upgrade() async throws -> any Comment
}

public extension CommentStubProviding {
    var actorId_: ActorIdentifier? { nil }
    var content_: String? { nil }
    var created_: Date? { nil }
    var updated_: Date? { nil }
    var deleted_: Bool? { nil }
    var creatorId_: Int? { nil }
    var postId_: Int? { nil }
    var parentCommentIds_: [Int]? { nil }
    var distinguished_: Bool? { nil }
    var removed_: Bool? { nil }
    var removedManager_: StateManager<Bool>? { nil }
    var languageId_: Int? { nil }
    
    var creator_: (any Person)? { nil }
    var post_: UnifiedPostModel? { nil }
    var community_: (any Community)? { nil }
    var votes_: VotesModel? { nil }
    var saved_: Bool? { nil }
    var creatorIsModerator_: Bool? { nil }
    var creatorIsAdmin_: Bool? { nil }
    var creatorBannedFromCommunity_: Bool? { nil }
    var commentCount_: Int? { nil }
    
    var depth_: Int? { parentCommentIds_?.count }
}
