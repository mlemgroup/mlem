//
//  Person4Providing.swift
//
//
//  Created by Sjmarf on 20/05/2024.
//

import Foundation

public protocol Person4Providing: Person3Providing {
    var person4: Person4 { get }
    
    var email: String? { get }
    var showNsfw: Bool { get }
    var theme: String { get }
    var defaultListingType: ListingType { get }
    var interfaceLanguage: String { get }
    var showAvatars: Bool { get }
    var sendNotificationsToEmail: Bool { get }
    var showScores: Bool { get }
    var showBotAccounts: Bool { get }
    var showReadPosts: Bool { get }
    var discussionLanguageIds: Set<Int> { get }
    var emailVerified: Bool { get }
    var acceptedApplication: Bool { get }
    var openLinksInNewTab: Bool? { get }
    var blurNsfw: Bool? { get }
    var autoExpandImages: Bool? { get }
    var infiniteScrollEnabled: Bool? { get }
    var postListingMode: ApiPostListingMode? { get }
    var totp2faEnabled: Bool? { get }
    var enableKeyboardNavigation: Bool? { get }
    var enableAnimatedImages: Bool? { get }
    var collapseBotComments: Bool? { get }
}

public extension Person4Providing {
    var person3: Person3 { person4.person3 }
    
    var email: String? { person4.email }
    var showNsfw: Bool { person4.showNsfw }
    var theme: String { person4.theme }
    var defaultListingType: ListingType { person4.defaultListingType }
    var interfaceLanguage: String { person4.interfaceLanguage }
    var showAvatars: Bool { person4.showAvatars }
    var sendNotificationsToEmail: Bool { person4.sendNotificationsToEmail }
    var showScores: Bool { person4.showScores }
    var showBotAccounts: Bool { person4.showBotAccounts }
    var showReadPosts: Bool { person4.showReadPosts }
    var discussionLanguageIds: Set<Int> { person4.discussionLanguageIds }
    var emailVerified: Bool { person4.emailVerified }
    var acceptedApplication: Bool { person4.acceptedApplication }
    var openLinksInNewTab: Bool? { person4.openLinksInNewTab }
    var blurNsfw: Bool? { person4.blurNsfw }
    var autoExpandImages: Bool? { person4.autoExpandImages }
    var infiniteScrollEnabled: Bool? { person4.infiniteScrollEnabled }
    var postListingMode: ApiPostListingMode? { person4.postListingMode }
    var totp2faEnabled: Bool? { person4.totp2faEnabled }
    var enableKeyboardNavigation: Bool? { person4.enableKeyboardNavigation }
    var enableAnimatedImages: Bool? { person4.enableAnimatedImages }
    var collapseBotComments: Bool? { person4.collapseBotComments }
    
    var email_: String? { person4.email }
    var showNsfw_: Bool? { person4.showNsfw }
    var theme_: String? { person4.theme }
    var defaultListingType_: ListingType? { person4.defaultListingType }
    var interfaceLanguage_: String? { person4.interfaceLanguage }
    var showAvatars_: Bool? { person4.showAvatars }
    var sendNotificationsToEmail_: Bool? { person4.sendNotificationsToEmail }
    var showScores_: Bool? { person4.showScores }
    var showBotAccounts_: Bool? { person4.showBotAccounts }
    var showReadPosts_: Bool? { person4.showReadPosts }
    var discussionLanguageIds_: Set<Int>? { person4.discussionLanguageIds }
    var emailVerified_: Bool? { person4.emailVerified }
    var acceptedApplication_: Bool? { person4.acceptedApplication }
    var openLinksInNewTab_: Bool? { person4.openLinksInNewTab }
    var blurNsfw_: Bool? { person4.blurNsfw }
    var autoExpandImages_: Bool? { person4.autoExpandImages }
    var infiniteScrollEnabled_: Bool? { person4.infiniteScrollEnabled }
    var postListingMode_: ApiPostListingMode? { person4.postListingMode }
    var totp2faEnabled_: Bool? { person4.totp2faEnabled }
    var enableKeyboardNavigation_: Bool? { person4.enableKeyboardNavigation }
    var enableAnimatedImages_: Bool? { person4.enableAnimatedImages }
    var collapseBotComments_: Bool? { person4.collapseBotComments }
}

public extension Person4Providing {
    var moderatedCommunityActorIds: Set<ActorIdentifier> { .init(moderatedCommunities.map(\.actorId)) }
}
