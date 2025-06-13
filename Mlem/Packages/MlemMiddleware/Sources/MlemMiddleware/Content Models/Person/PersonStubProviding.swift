//
//  AccountProviding.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public protocol PersonStubProviding: ContentModel, Resolvable {
    // From Person1Providing.
    var actorId_: ActorIdentifier? { get }
    var id_: Int? { get }
    var created_: Date? { get }
    var instanceId_: Int? { get }
    var updated_: Date? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var matrixId_: String? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var deleted_: Bool? { get }
    var isBot_: Bool? { get }
    var instanceBan_: InstanceBanType? { get }
    var blocked_: Bool? { get }
    
    // From Person2Providing.
    var postCount_: Int? { get }
    var commentCount_: Int? { get }
    
    // From Person3Providing.
    var instance_: Instance1? { get }
    var moderatedCommunities_: [Community1]? { get }
    
    // From Person4Providing.
    var isAdmin_: Bool? { get }
    var email_: String? { get }
    var showNsfw_: Bool? { get }
    var theme_: String? { get }
    var defaultSortType_: ApiSortType? { get }
    var defaultListingType_: ListingType? { get }
    var interfaceLanguage_: String? { get }
    var showAvatars_: Bool? { get }
    var sendNotificationsToEmail_: Bool? { get }
    var showScores_: Bool? { get }
    var showBotAccounts_: Bool? { get }
    var showReadPosts_: Bool? { get }
    var discussionLanguageIds_: Set<Int>? { get }
    var emailVerified_: Bool? { get }
    var acceptedApplication_: Bool? { get }
    var openLinksInNewTab_: Bool? { get }
    var blurNsfw_: Bool? { get }
    var autoExpandImages_: Bool? { get }
    var infiniteScrollEnabled_: Bool? { get }
    var postListingMode_: ApiPostListingMode? { get }
    var totp2faEnabled_: Bool? { get }
    var enableKeyboardNavigation_: Bool? { get }
    var enableAnimatedImages_: Bool? { get }
    var collapseBotComments_: Bool? { get }
    
    func upgrade() async throws -> any Person
}

public extension PersonStubProviding {
    static var identifierPrefix: String { "@" }
    
    var actorId_: ActorIdentifier? { nil }
    var id_: Int? { nil }
    var created_: Date? { nil }
    var instanceId_: Int? { nil }
    var updated_: Date? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var matrixId_: String? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var deleted_: Bool? { nil }
    var isBot_: Bool? { nil }
    var instanceBan_: InstanceBanType? { nil }
    var blocked_: Bool? { nil }
    
    var postCount_: Int? { nil }
    var commentCount_: Int? { nil }
    
    var instance_: Instance1? { nil }
    var moderatedCommunities_: [Community1]? { nil }
    
    var isAdmin_: Bool? { nil }
    var email_: String? { nil }
    var showNsfw_: Bool? { nil }
    var theme_: String? { nil }
    var defaultSortType_: ApiSortType? { nil }
    var defaultListingType_: ListingType? { nil }
    var interfaceLanguage_: String? { nil }
    var showAvatars_: Bool? { nil }
    var sendNotificationsToEmail_: Bool? { nil }
    var showScores_: Bool? { nil }
    var showBotAccounts_: Bool? { nil }
    var showReadPosts_: Bool? { nil }
    var discussionLanguageIds_: Set<Int>? { nil }
    var emailVerified_: Bool? { nil }
    var acceptedApplication_: Bool? { nil }
    var openLinksInNewTab_: Bool? { nil }
    var blurNsfw_: Bool? { nil }
    var autoExpandImages_: Bool? { nil }
    var infiniteScrollEnabled_: Bool? { nil }
    var postListingMode_: ApiPostListingMode? { nil }
    var totp2faEnabled_: Bool? { nil }
    var enableKeyboardNavigation_: Bool? { nil }
    var enableAnimatedImages_: Bool? { nil }
    var collapseBotComments_: Bool? { nil }
}
