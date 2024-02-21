//
//  SaveUserSettingsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SaveUserSettingsRequest: ApiPutRequest {
    typealias Body = ApiSaveUserSettings
    typealias Response = ApiSuccessResponse

    let path = "/user/save_user_settings"
    let body: Body?

    init(
        showNsfw: Bool?,
        blurNsfw: Bool?,
        autoExpand: Bool?,
        showScores: Bool?,
        theme: String?,
        defaultSortType: ApiSortType?,
        defaultListingType: ApiListingType?,
        interfaceLanguage: String?,
        avatar: URL?,
        banner: URL?,
        displayName: String?,
        email: String?,
        bio: String?,
        matrixUserId: String?,
        showAvatars: Bool?,
        sendNotificationsToEmail: Bool?,
        botAccount: Bool?,
        showBotAccounts: Bool?,
        showReadPosts: Bool?,
        discussionLanguages: [Int]?,
        openLinksInNewTab: Bool?,
        infiniteScrollEnabled: Bool?,
        postListingMode: ApiPostListingMode?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?,
        showNewPostNotifs: Bool?,
        generateTotp2fa: Bool?
    ) {
        self.body = .init(
            showNsfw: showNsfw,
            blurNsfw: blurNsfw,
            autoExpand: autoExpand,
            showScores: showScores,
            theme: theme,
            defaultSortType: defaultSortType,
            defaultListingType: defaultListingType,
            interfaceLanguage: interfaceLanguage,
            avatar: avatar,
            banner: banner,
            displayName: displayName,
            email: email,
            bio: bio,
            matrixUserId: matrixUserId,
            showAvatars: showAvatars,
            sendNotificationsToEmail: sendNotificationsToEmail,
            botAccount: botAccount,
            showBotAccounts: showBotAccounts,
            showReadPosts: showReadPosts,
            discussionLanguages: discussionLanguages,
            openLinksInNewTab: openLinksInNewTab,
            infiniteScrollEnabled: infiniteScrollEnabled,
            postListingMode: postListingMode,
            enableKeyboardNavigation: enableKeyboardNavigation,
            enableAnimatedImages: enableAnimatedImages,
            collapseBotComments: collapseBotComments,
            showNewPostNotifs: showNewPostNotifs,
            generateTotp2fa: generateTotp2fa
        )
    }
}
