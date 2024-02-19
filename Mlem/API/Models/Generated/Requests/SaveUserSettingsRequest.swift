//
//  SaveUserSettingsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct SaveUserSettingsRequest: APIPutRequest {
    typealias Body = APISaveUserSettings
    typealias Response = APISuccessResponse

    let path = "/user/save_user_settings"
    let body: Body?

    init(
        showNsfw: Bool?,
        blurNsfw: Bool?,
        autoExpand: Bool?,
        showScores: Bool?,
        theme: String?,
        defaultSortType: APISortType?,
        defaultListingType: APIListingType?,
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
        postListingMode: APIPostListingMode?,
        enableKeyboardNavigation: Bool?,
        enableAnimatedImages: Bool?,
        collapseBotComments: Bool?
    ) {
        self.body = .init(
            show_nsfw: showNsfw,
            blur_nsfw: blurNsfw,
            auto_expand: autoExpand,
            show_scores: showScores,
            theme: theme,
            default_sort_type: defaultSortType,
            default_listing_type: defaultListingType,
            interface_language: interfaceLanguage,
            avatar: avatar,
            banner: banner,
            display_name: displayName,
            email: email,
            bio: bio,
            matrix_user_id: matrixUserId,
            show_avatars: showAvatars,
            send_notifications_to_email: sendNotificationsToEmail,
            bot_account: botAccount,
            show_bot_accounts: showBotAccounts,
            show_read_posts: showReadPosts,
            discussion_languages: discussionLanguages,
            open_links_in_new_tab: openLinksInNewTab,
            infinite_scroll_enabled: infiniteScrollEnabled,
            post_listing_mode: postListingMode,
            enable_keyboard_navigation: enableKeyboardNavigation,
            enable_animated_images: enableAnimatedImages,
            collapse_bot_comments: collapseBotComments
        )
    }
}
