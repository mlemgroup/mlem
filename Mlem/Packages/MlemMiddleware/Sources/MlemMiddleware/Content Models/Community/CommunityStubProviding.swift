//
//  CommunityStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

public protocol CommunityStubProviding: ContentModel, Resolvable {
    // From Community1Providing.
    var actorId_: ActorIdentifier? { get }
    var id_: Int? { get }
    var created_: Date? { get }
    var instanceId_: Int? { get }
    var updated_: Date? { get }
    var name_: String? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var removed_: Bool? { get }
    var removedManager_: StateManager<Bool>? { get }
    var deleted_: Bool? { get }
    var nsfw_: Bool? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var hidden_: Bool? { get }
    var onlyModeratorsCanPost_: Bool? { get }
    var blocked_: Bool? { get }
    var purged_: Bool? { get }
    var visibility_: ApiCommunityVisibility? { get }
    
    // From Community2Providing.
    var subscribed_: Bool? { get }
    var favorited_: Bool? { get }
    var subscriberCount_: Int? { get }
    var localSubscriberCount_: Int? { get }
    var postCount_: Int? { get }
    var commentCount_: Int? { get }
    var activeUserCount_: ActiveUserCount? { get }
    var subscriptionTier_: SubscriptionTier? { get }
    
    // From Community3Providing.
    var instance_: Instance1? { get }
    var moderators_: [Person1]? { get }
    var discussionLanguages_: [Int]? { get }
    var defaultPostLanguage_: Int? { get }
    
    func upgrade() async throws -> any Community
}

public extension CommunityStubProviding {
    static var identifierPrefix: String { "!" }
    
    // From Community1Providing.
    var actorId_: ActorIdentifier? { nil }
    var id_: Int? { nil }
    var created_: Date? { nil }
    var instanceId_: Int? { nil }
    var updated_: Date? { nil }
    var name_: String? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var removed_: Bool? { nil }
    var removedManager_: StateManager<Bool>? { nil }
    var deleted_: Bool? { nil }
    var nsfw_: Bool? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var hidden_: Bool? { nil }
    var onlyModeratorsCanPost_: Bool? { nil }
    var blocked_: Bool? { nil }
    var purged_: Bool? { nil }
    var visibility_: ApiCommunityVisibility? { nil }
    
    // From Community2Providing.
    var subscribed_: Bool? { nil }
    var favorited_: Bool? { nil }
    var subscriberCount_: Int? { nil }
    var localSubscriberCount_: Int? { nil }
    var postCount_: Int? { nil }
    var commentCount_: Int? { nil }
    var activeUserCount_: ActiveUserCount? { nil }
    var subscriptionTier_: SubscriptionTier? { nil }
    
    // From Community3Providing.
    var instance_: Instance1? { nil }
    var moderators_: [Person1]? { nil }
    var discussionLanguages_: [Int]? { nil }
    var defaultPostLanguage_: Int? { nil }
}
