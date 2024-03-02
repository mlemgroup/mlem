//
//  CommunityStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol CommunityStubProviding: CommunityOrPersonStub {
    // From Community1Providing.
    var id_: Int? { get }
    var creationDate_: Date? { get }
    var updatedDate_: Date? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var removed_: Bool? { get }
    var deleted_: Bool? { get }
    var nsfw_: Bool? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var hidden_: Bool? { get }
    var onlyModeratorsCanPost_: Bool? { get }
    var blocked_: Bool? { get }
    
    // From Community2Providing.
    var subscribed_: Bool? { get }
    var favorited_: Bool? { get }
    var subscriberCount_: Int? { get }
    var postCount_: Int? { get }
    var commentCount_: Int? { get }
    var activeUserCount_: ActiveUserCount? { get }
    var subscriptionTier_: SubscriptionTier? { get }
    
    // From Community3Providing.
    var instance_: Instance1? { get }
    var moderators_: [Person1]? { get }
    var discussionLanguages_: [Int]? { get }
    var defaultPostLanguage_: Int? { get }
    
    func upgrade() async throws -> Community3
}

extension CommunityStubProviding {
    static var identifierPrefix: String { "!" }
    
    // From Community1Providing.
    var id_: Int? { nil }
    var creationDate_: Date? { nil }
    var updatedDate_: Date? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var removed_: Bool? { nil }
    var deleted_: Bool? { nil }
    var nsfw_: Bool? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var hidden_: Bool? { nil }
    var onlyModeratorsCanPost_: Bool? { nil }
    var blocked_: Bool? { nil }
    
    // From Community2Providing.
    var subscribed_: Bool? { nil }
    var favorited_: Bool? { nil }
    var subscriberCount_: Int? { nil }
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

enum UpgradeError: Error {
    case entityNotFound
}

extension CommunityStubProviding {
    func upgrade() async throws -> Community3 {
        guard let community = try await api.getCommunity(actorId: actorId) else {
            throw UpgradeError.entityNotFound
        }
        return community
    }
}
