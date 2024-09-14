//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import MlemMiddleware
import UIKit

/// Mirror of Settings but without any AppStorage complexity and fully optionalized.
struct CodableSettings: Codable {
    var a11y_markReadType: String // TODO: pending a11y mark read
    var a11y_readBarThickness: Int
    var a11y_websiteThumbnailIcon: Bool
    var accounts_defaultId: Int?
    var accounts_grouped: Bool
    var accounts_sort: AccountSortMode
    var accounts_keepPlace: Bool
    var appearance_interfaceStyle: UIUserInterfaceStyle
    var appearance_palette: PaletteOption
    var appearance_showSettingsIcons: Bool
    var behavior_biometricUnlock: Bool
    var behavior_confirmImageUploads: Bool
    var behavior_enableQuickSwipes: Bool
    var behavior_hapticLevel: HapticPriority
    var behavior_internetSpeed: InternetSpeed
    var behavior_upvoteOnSave: Bool
    var comment_behaviors_collapseChildren: Bool
    var comment_compact: Bool
    var comment_defaultSort: ApiCommentSortType
    var comment_gestures_tapToCollapse: Bool
    var comment_jumpButton: CommentJumpButtonLocation
    var comment_showCreatorInstance: Bool
    var community_showAvatar: Bool
    var community_showBanner: Bool
    var community_showInstance: Bool
    var dev_developerMode: Bool
    var feed_default: FeedSelection
    var feed_markReadOnScroll: Bool
    var feed_showRead: Bool
    var inbox_badge_includeApplications: Bool
    var inbox_badge_includeMessageReports: Bool
    var inbox_badge_includeMod: Bool
    var inbox_badge_includePersonal: Bool
    var inbox_showRead: Bool
    var links_displayMode: String // TODO: pending easy-tap links
    var links_openInBrowser: Bool
    var links_readerMode: Bool
    var menus_allModActions: Bool
    var menus_modActionGrouping: String // TODO: pending mod actions
    var post_defaultSort: ApiSortType
    var post_fallbackSort: ApiSortType
    var post_limitImageHeight: Bool
    var post_showCreator: Bool
    var post_showCreatorInstance: Bool
    var post_showSubscribedStatus: Bool
    var post_showWebsitePreview: Bool
    var post_size: PostSize
    var post_thumbnailLocation: ThumbnailLocation
    var post_webPreview_showHost: Bool
    var post_webPreview_showIcon: Bool
    var profile_showBanner: Bool
    var privacy_autoBypassImageProxy: Bool
    var safety_blurNsfw: NsfwBlurBehavior
    var safety_enableModlogWarning: Bool
    var safety_enableNsfwCommunityWarning: Bool
    var tab_gestures_enableLongPress: Bool
    var tab_gestures_enableSwipeUp: Bool
    var tab_profile_labelType: String // TODO: pending tab label customization
    var tab_profile_showAvatar: Bool
    var tab_showNames: Bool
    var person_showAvatar: Bool
    var person_showInstance: Bool
    var status_bypassImageProxyShown: Bool
    var subscriptions_instanceLocation: InstanceLocation
    var subscriptions_sort: SubscriptionListSort
    
    // swiftlint:disable line_length function_body_length
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.a11y_markReadType = try container.decodeIfPresent(String.self, forKey: .a11y_markReadType) ?? "bar"
        self.a11y_readBarThickness = try container.decodeIfPresent(Int.self, forKey: .a11y_readBarThickness) ?? 3
        self.a11y_websiteThumbnailIcon = try container.decodeIfPresent(Bool.self, forKey: .a11y_websiteThumbnailIcon) ?? false
        self.accounts_defaultId = try container.decodeIfPresent(Int?.self, forKey: .accounts_defaultId) ?? nil
        self.accounts_grouped = try container.decodeIfPresent(Bool.self, forKey: .accounts_grouped) ?? false
        self.accounts_sort = try container.decodeIfPresent(AccountSortMode.self, forKey: .accounts_sort) ?? .name
        self.accounts_keepPlace = try container.decodeIfPresent(Bool.self, forKey: .accounts_keepPlace) ?? false
        self.appearance_interfaceStyle = try container.decodeIfPresent(UIUserInterfaceStyle.self, forKey: .appearance_interfaceStyle) ?? .unspecified
        self.appearance_palette = try container.decodeIfPresent(PaletteOption.self, forKey: .appearance_palette) ?? .standard
        self.appearance_showSettingsIcons = try container.decodeIfPresent(Bool.self, forKey: .appearance_showSettingsIcons) ?? true
        self.behavior_biometricUnlock = try container.decodeIfPresent(Bool.self, forKey: .behavior_biometricUnlock) ?? false
        self.behavior_confirmImageUploads = try container.decodeIfPresent(Bool.self, forKey: .behavior_confirmImageUploads) ?? true
        self.behavior_enableQuickSwipes = try container.decodeIfPresent(Bool.self, forKey: .behavior_enableQuickSwipes) ?? true
        self.behavior_hapticLevel = try container.decodeIfPresent(HapticPriority.self, forKey: .behavior_hapticLevel) ?? .high
        self.behavior_internetSpeed = try container.decodeIfPresent(InternetSpeed.self, forKey: .behavior_internetSpeed) ?? .fast
        self.behavior_upvoteOnSave = try container.decodeIfPresent(Bool.self, forKey: .behavior_upvoteOnSave) ?? false
        self.comment_behaviors_collapseChildren = try container.decodeIfPresent(Bool.self, forKey: .comment_behaviors_collapseChildren) ?? false
        self.comment_compact = try container.decodeIfPresent(Bool.self, forKey: .comment_compact) ?? false
        self.comment_defaultSort = try container.decodeIfPresent(ApiCommentSortType.self, forKey: .comment_defaultSort) ?? .hot
        self.comment_gestures_tapToCollapse = try container.decodeIfPresent(Bool.self, forKey: .comment_gestures_tapToCollapse) ?? true
        self.comment_jumpButton = try container.decodeIfPresent(CommentJumpButtonLocation.self, forKey: .comment_jumpButton) ?? .bottomTrailing
        self.comment_showCreatorInstance = try container.decodeIfPresent(Bool.self, forKey: .comment_showCreatorInstance) ?? true
        self.community_showAvatar = try container.decodeIfPresent(Bool.self, forKey: .community_showAvatar) ?? true
        self.community_showBanner = try container.decodeIfPresent(Bool.self, forKey: .community_showBanner) ?? true
        self.community_showInstance = try container.decodeIfPresent(Bool.self, forKey: .community_showInstance) ?? true
        self.dev_developerMode = try container.decodeIfPresent(Bool.self, forKey: .dev_developerMode) ?? false
        self.feed_default = try container.decodeIfPresent(FeedSelection.self, forKey: .feed_default) ?? .subscribed
        self.feed_markReadOnScroll = try container.decodeIfPresent(Bool.self, forKey: .feed_markReadOnScroll) ?? false
        self.feed_showRead = try container.decodeIfPresent(Bool.self, forKey: .feed_showRead) ?? true
        self.inbox_badge_includeApplications = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeApplications) ?? true
        self.inbox_badge_includeMessageReports = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeMessageReports) ?? true
        self.inbox_badge_includeMod = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeMod) ?? true
        self.inbox_badge_includePersonal = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includePersonal) ?? true
        self.inbox_showRead = try container.decodeIfPresent(Bool.self, forKey: .inbox_showRead) ?? true
        self.links_displayMode = try container.decodeIfPresent(String.self, forKey: .links_displayMode) ?? "contextual"
        self.links_openInBrowser = try container.decodeIfPresent(Bool.self, forKey: .links_openInBrowser) ?? false
        self.links_readerMode = try container.decodeIfPresent(Bool.self, forKey: .links_readerMode) ?? false
        self.menus_allModActions = try container.decodeIfPresent(Bool.self, forKey: .menus_allModActions) ?? false
        self.menus_modActionGrouping = try container.decodeIfPresent(String.self, forKey: .menus_modActionGrouping) ?? "none"
        self.post_defaultSort = try container.decodeIfPresent(ApiSortType.self, forKey: .post_defaultSort) ?? .hot
        self.post_fallbackSort = try container.decodeIfPresent(ApiSortType.self, forKey: .post_fallbackSort) ?? .hot
        self.post_limitImageHeight = try container.decodeIfPresent(Bool.self, forKey: .post_limitImageHeight) ?? true
        self.post_showCreator = try container.decodeIfPresent(Bool.self, forKey: .post_showCreator) ?? true
        self.post_showCreatorInstance = try container.decodeIfPresent(Bool.self, forKey: .post_showCreatorInstance) ?? true
        self.post_showSubscribedStatus = try container.decodeIfPresent(Bool.self, forKey: .post_showSubscribedStatus) ?? false
        self.post_showWebsitePreview = try container.decodeIfPresent(Bool.self, forKey: .post_showWebsitePreview) ?? true
        self.post_size = try container.decodeIfPresent(PostSize.self, forKey: .post_size) ?? .large
        self.post_thumbnailLocation = try container.decodeIfPresent(ThumbnailLocation.self, forKey: .post_thumbnailLocation) ?? .left
        self.post_webPreview_showHost = try container.decodeIfPresent(Bool.self, forKey: .post_webPreview_showHost) ?? true
        self.post_webPreview_showIcon = try container.decodeIfPresent(Bool.self, forKey: .post_webPreview_showIcon) ?? true
        self.privacy_autoBypassImageProxy = try container.decode(Bool.self, forKey: .privacy_autoBypassImageProxy) ?? false
        self.profile_showBanner = try container.decodeIfPresent(Bool.self, forKey: .profile_showBanner) ?? true
        self.safety_blurNsfw = try container.decodeIfPresent(NsfwBlurBehavior.self, forKey: .safety_blurNsfw) ?? .always
        self.safety_enableModlogWarning = try container.decodeIfPresent(Bool.self, forKey: .safety_enableModlogWarning) ?? true
        self.safety_enableNsfwCommunityWarning = try container.decodeIfPresent(Bool.self, forKey: .safety_enableNsfwCommunityWarning) ?? true
        self.tab_gestures_enableLongPress = try container.decodeIfPresent(Bool.self, forKey: .tab_gestures_enableLongPress) ?? true
        self.tab_gestures_enableSwipeUp = try container.decodeIfPresent(Bool.self, forKey: .tab_gestures_enableSwipeUp) ?? true
        self.tab_profile_labelType = try container.decodeIfPresent(String.self, forKey: .tab_profile_labelType) ?? "nickname"
        self.tab_profile_showAvatar = try container.decodeIfPresent(Bool.self, forKey: .tab_profile_showAvatar) ?? true
        self.tab_showNames = try container.decodeIfPresent(Bool.self, forKey: .tab_showNames) ?? true
        self.person_showAvatar = try container.decodeIfPresent(Bool.self, forKey: .person_showAvatar) ?? true
        self.person_showInstance = try container.decodeIfPresent(Bool.self, forKey: .person_showInstance) ?? true
        self.status_bypassImageProxyShown = try container.decodeIfPresent(Bool.self, forKey: .status_bypassImageProxyShown) ?? false
        self.subscriptions_instanceLocation = try container.decodeIfPresent(InstanceLocation.self, forKey: .subscriptions_instanceLocation) ?? (UIDevice.isPad ? .bottom : .trailing)
        self.subscriptions_sort = try container.decodeIfPresent(SubscriptionListSort.self, forKey: .subscriptions_sort) ?? .alphabetical
    }

    // swiftlint:enable line_length
    
    init(from settings: Settings) {
        self.a11y_markReadType = "bar"
        self.a11y_readBarThickness = 3
        self.a11y_websiteThumbnailIcon = false
        self.accounts_defaultId = nil
        self.accounts_grouped = settings.groupAccountSort
        self.accounts_sort = settings.accountSort
        self.accounts_keepPlace = settings.keepPlaceOnAccountSwitch
        self.appearance_interfaceStyle = settings.interfaceStyle
        self.appearance_palette = settings.colorPalette
        self.appearance_showSettingsIcons = true
        self.behavior_biometricUnlock = false
        self.behavior_confirmImageUploads = true
        self.behavior_enableQuickSwipes = settings.quickSwipesEnabled
        self.behavior_hapticLevel = settings.hapticLevel
        self.behavior_internetSpeed = settings.internetSpeed
        self.behavior_upvoteOnSave = settings.upvoteOnSave
        self.comment_behaviors_collapseChildren = false
        self.comment_compact = settings.compactComments
        self.comment_defaultSort = settings.commentSort
        self.comment_gestures_tapToCollapse = true
        self.comment_jumpButton = settings.jumpButton
        self.comment_showCreatorInstance = true
        self.community_showAvatar = settings.showCommunityAvatar
        self.community_showBanner = true
        self.community_showInstance = true
        self.dev_developerMode = settings.developerMode
        self.feed_default = settings.defaultFeed
        self.feed_markReadOnScroll = settings.markReadOnScroll
        self.feed_showRead = settings.showReadInFeed
        self.inbox_badge_includeApplications = true
        self.inbox_badge_includeMessageReports = true
        self.inbox_badge_includeMod = true
        self.inbox_badge_includePersonal = true
        self.inbox_showRead = settings.showReadInInbox
        self.links_displayMode = "contextual"
        self.links_openInBrowser = settings.openLinksInBrowser
        self.links_readerMode = settings.openLinksInReaderMode
        self.menus_allModActions = false
        self.menus_modActionGrouping = "none"
        self.post_defaultSort = settings.defaultPostSort
        self.post_fallbackSort = settings.fallbackPostSort
        self.post_limitImageHeight = true
        self.post_showCreator = settings.showPostCreator
        self.post_showCreatorInstance = true
        self.post_showSubscribedStatus = false
        self.post_showWebsitePreview = true
        self.post_size = settings.postSize
        self.post_thumbnailLocation = settings.thumbnailLocation
        self.post_webPreview_showHost = true
        self.post_webPreview_showIcon = true
        self.profile_showBanner = true
        self.safety_blurNsfw = settings.blurNsfw
        self.safety_enableModlogWarning = true
        self.safety_enableNsfwCommunityWarning = settings.showNsfwCommunityWarning
        self.tab_gestures_enableLongPress = true
        self.tab_gestures_enableSwipeUp = true
        self.tab_profile_labelType = "nickname"
        self.tab_profile_showAvatar = true
        self.tab_showNames = true
        self.person_showAvatar = settings.showPersonAvatar
        self.person_showInstance = true
        self.privacy_autoBypassImageProxy = settings.autoBypassImageProxy
        self.status_bypassImageProxyShown = settings.bypassImageProxyShown
        self.subscriptions_instanceLocation = settings.subscriptionInstanceLocation
        self.subscriptions_sort = settings.subscriptionSort
    }
    // swiftlint:enable function_body_length
}
