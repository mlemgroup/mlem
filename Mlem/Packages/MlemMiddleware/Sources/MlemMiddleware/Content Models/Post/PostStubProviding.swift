//
//  PostStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public protocol PostStubProviding: ContentModel, Resolvable {
    // From Post1Providing. These are defined as nil in the extension below
    var actorId_: ActorIdentifier? { get }
    var creatorId_: Int? { get }
    var communityId_: Int? { get }
    var title_: String? { get }
    var content_: String? { get }
    var linkUrl_: URL? { get }
    var deleted_: Bool? { get }
    var embed_: PostEmbed? { get }
    var pinnedCommunity_: Bool? { get }
    var pinnedInstance_: Bool? { get }
    var locked_: Bool? { get }
    var pinnedCommunityManager_: StateManager<Bool>? { get }
    var pinnedInstanceManager_: StateManager<Bool>? { get }
    var lockedManager_: StateManager<Bool>? { get }
    var nsfw_: Bool? { get }
    var created_: Date? { get }
    var removed_: Bool? { get }
    var removedManager_: StateManager<Bool>? { get }
    var thumbnailUrl_: URL? { get }
    var updated_: Date? { get }
    var languageId_: Int? { get }
    var altText_: String? { get }
    
    // From Post2Providing. These are defined as nil in the extension below
    var creator_: (any Person)? { get }
    var community_: (any Community)? { get }
    var creatorIsModerator_: Bool? { get }
    var creatorIsAdmin_: Bool? { get }
    var bannedFromCommunity_: Bool? { get }
    var commentCount_: Int? { get }
    var unreadCommentCount_: Int? { get }
    var votes_: VotesModel? { get }
    var saved_: Bool? { get }
    var read_: Bool? { get }
    var hidden_: Bool? { get }
    
    // From Post3Providing. These are defined as nil in the extension below
    var communityModerators_: [Person1]? { get }
    var crossPosts_: [Post2]? { get }
    
    func upgrade() async throws -> any Post
}

public extension PostStubProviding {
    var actorId_: ActorIdentifier? { nil }
    var creatorId_: Int? { nil }
    var communityId_: Int? { nil }
    var title_: String? { nil }
    var content_: String? { nil }
    var linkUrl_: URL? { nil }
    var deleted_: Bool? { nil }
    var embed_: PostEmbed? { nil }
    var pinnedCommunity_: Bool? { nil }
    var pinnedInstance_: Bool? { nil }
    var locked_: Bool? { nil }
    var pinnedCommunityManager_: StateManager<Bool>? { nil }
    var pinnedInstanceManager_: StateManager<Bool>? { nil }
    var lockedManager_: StateManager<Bool>? { nil }
    var nsfw_: Bool? { nil }
    var created_: Date? { nil }
    var removed_: Bool? { nil }
    var removedManager_: StateManager<Bool>? { nil }
    var thumbnailUrl_: URL? { nil }
    var updated_: Date? { nil }
    var languageId_: Int? { nil }
    var altText_: String? { nil }
    
    var creator_: (any Person)? { nil }
    var community_: (any Community)? { nil }
    var creatorIsModerator_: Bool? { nil }
    var creatorIsAdmin_: Bool? { nil }
    var bannedFromCommunity_: Bool? { nil }
    var commentCount_: Int? { nil }
    var votes_: VotesModel? { nil }
    var unreadCommentCount_: Int? { nil }
    var saved_: Bool? { nil }
    var read_: Bool? { nil }
    var hidden_: Bool? { nil }
    
    var communityModerators_: [Person1]? { nil }
    var crossPosts_: [Post2]? { nil }
}
