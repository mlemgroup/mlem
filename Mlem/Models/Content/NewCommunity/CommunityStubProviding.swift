//
//  CommunityStubProviding.swift
//  Mlem
//
//  Created by Sjmarf on 15/02/2024.
//

import Foundation

protocol CommunityStubProviding: CommunityOrPersonStub {
    // From Community1Providing. These are defined as nil in the extension below
    var creationDate: Date? { get }
    var updatedDate: Date? { get }
    var displayName: String? { get }
    var description: String? { get }
    var removed: Bool? { get }
    var deleted: Bool? { get }
    var nsfw: Bool? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var hidden: Bool? { get }
    var onlyModeratorsCanPost: Bool? { get }
    var blocked: Bool? { get }
    
    // From Community2Providing. These are defined as nil in the extension below
    var subscribed: Bool? { get }
    var favorited: Bool? { get }
    var subscriberCount: Int? { get }
    var postCount: Int? { get }
    var commentCount: Int? { get }
    var activeUserCount: ActiveUserCount? { get }
    var subscriptionTier: SubscriptionTier? { get }
    
    // From Community3Providing. These are defined as nil in the extension below
    var instance: Instance1? { get }
    var moderators: [User1]? { get }
    var discussionLanguages: [Int]? { get }
    var defaultPostLanguage: Int? { get }
}

extension CommunityStubProviding {
    static var identifierPrefix: String { "!" }
    
    var id: Int? { nil }
    var creationDate: Date? { nil }
    var updatedDate: Date? { nil }
    var displayName: String? { nil }
    var description: String? { nil }
    var removed: Bool? { nil }
    var deleted: Bool? { nil }
    var nsfw: Bool? { nil }
    var avatar: URL? { nil }
    var banner: URL? { nil }
    var hidden: Bool? { nil }
    var onlyModeratorsCanPost: Bool? { nil }
    var blocked: Bool? { nil }
    
    var subscribed: Bool? { nil }
    var favorited: Bool? { nil }
    var subscriberCount: Int? { nil }
    var postCount: Int? { nil }
    var commentCount: Int? { nil }
    var activeUserCount: ActiveUserCount? { nil }
    var subscriptionTier: SubscriptionTier? { nil }
    
    var instance: Instance1? { nil }
    var moderators: [User1]? { nil }
    var discussionLanguages: [Int]? { nil }
    var defaultPostLanguage: Int? { nil }
}

enum UpgradeError: Error {
    case entityNotFound
}

extension CommunityStubProviding {    
    func upgrade() async throws -> Community3 {
        guard let communityView = try await source.api.getCommunity(actorId: actorId) else {
            throw UpgradeError.entityNotFound
        }
        let communityResponse = try await source.api.getCommunity(id: communityView.id)
        return source.caches.community3.createModel(source: source, for: communityResponse)
    }
}
