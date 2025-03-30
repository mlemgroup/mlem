//
//  Person4Providing.swift
//
//
//  Created by Sjmarf on 20/05/2024.
//

import Foundation

public protocol Person4Providing: Person3Providing {
    var person4: Person4 { get }
    
    var voteDisplayMode: ApiLocalUserVoteDisplayMode? { get }
    var email: String? { get }
    var showNsfw: Bool { get }
    var theme: String { get }
    var defaultSortType: ApiSortType { get }
    var defaultListingType: ApiListingType { get }
    var interfaceLanguage: String { get }
    var showAvatars: Bool { get }
    var sendNotificationsToEmail: Bool { get }
    var showScores: Bool { get }
    var showBotAccounts: Bool { get }
    var showReadPosts: Bool { get }
    var discussionLanguageIds: Set<Int> { get }
    var showNewPostNotifs: Bool? { get }
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
    
    var voteDisplayMode: ApiLocalUserVoteDisplayMode? { person4.voteDisplayMode }
    var email: String? { person4.email }
    var showNsfw: Bool { person4.showNsfw }
    var theme: String { person4.theme }
    var defaultSortType: ApiSortType { person4.defaultSortType }
    var defaultListingType: ApiListingType { person4.defaultListingType }
    var interfaceLanguage: String { person4.interfaceLanguage }
    var showAvatars: Bool { person4.showAvatars }
    var sendNotificationsToEmail: Bool { person4.sendNotificationsToEmail }
    var showScores: Bool { person4.showScores }
    var showBotAccounts: Bool { person4.showBotAccounts }
    var showReadPosts: Bool { person4.showReadPosts }
    var discussionLanguageIds: Set<Int> { person4.discussionLanguageIds }
    var showNewPostNotifs: Bool? { person4.showNewPostNotifs }
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
    
    var voteDisplayMode_: ApiLocalUserVoteDisplayMode? { person4.voteDisplayMode }
    var email_: String? { person4.email }
    var showNsfw_: Bool? { person4.showNsfw }
    var theme_: String? { person4.theme }
    var defaultSortType_: ApiSortType? { person4.defaultSortType }
    var defaultListingType_: ApiListingType? { person4.defaultListingType }
    var interfaceLanguage_: String? { person4.interfaceLanguage }
    var showAvatars_: Bool? { person4.showAvatars }
    var sendNotificationsToEmail_: Bool? { person4.sendNotificationsToEmail }
    var showScores_: Bool? { person4.showScores }
    var showBotAccounts_: Bool? { person4.showBotAccounts }
    var showReadPosts_: Bool? { person4.showReadPosts }
    var discussionLanguageIds_: Set<Int>? { person4.discussionLanguageIds }
    var showNewPostNotifs_: Bool? { person4.showNewPostNotifs }
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
