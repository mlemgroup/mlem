//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import SwiftUI
import UIKit

struct CodableSettings: Codable {
    var a11y_markReadType: String
    var a11y_readBarThickness: Int
    var a11y_websiteThumbnailIcon: Bool
    var accounts_defaultId: Int?
    var accounts_grouped: Bool
    var accounts_sort: String
    // var accounts_keepPlace: Bool
    var appearance_interfaceStyle: UIUserInterfaceStyle
    // var appearance_palette
    var appearance_showSettingsIcons: Bool
    var behavior_biometricUnlock: Bool
    var behavior_confirmImageUploads: Bool
    var behavior_hapticLevel: String
    var behavior_internetSpeed: String
    var behavior_upvoteOnSave: Bool
    var comment_behaviors_collapseChildren: Bool
    var comment_compact: Bool
    var comment_defaultSort: String
    var comment_gestures_tapToCollapse: Bool
    var comment_jumpButton: String
    var comment_showCreatorInstance: Bool
    var community_showAvatar: Bool
    var community_showBanner: Bool
    var community_showInstance: Bool
    var dev_developerMode: Bool
    var feed_default: String
    var feed_markReadOnScroll: Bool
    var feed_showRead: Bool
    var inbox_badge_includeApplications: Bool
    var inbox_badge_includeMessageReports: Bool
    var inbox_badge_includeMod: Bool
    var inbox_badge_includePersonal: Bool
    var inbox_showRead: Bool
    var links_displayMode: String
    var links_openInBrowser: Bool
    var links_readerMode: Bool
    var menus_allModActions: Bool
    var menus_modActionGrouping: String
    var post_defaultSort: String
    var post_fallbackSort: String
    var post_limitImageHeight: Bool
    var post_showCreator: Bool
    var post_showCreatorInstance: Bool
    var post_showSubscribedStatus: Bool
    var post_showWebsitePreview: Bool
    var post_size: String
    var post_thumbnailLocation: String
    var post_webPreview_showHost: Bool
    var post_webPreview_showIcon: Bool
    var profile_showBanner: Bool
    var safety_blurNsfw: String
    var safety_enableModlogWarning: Bool
    var tab_gestures_enableLongPress: Bool
    var tab_gestures_enableSwipeUp: Bool
    var tab_profile_labelType: String
    var tab_profile_showAvatar: Bool
    var tab_showNames: Bool
    var person_showAvatar: Bool
    // var person_showInstance: Bool
    
    // swiftlint:disable:next function_body_length
    init() {
        @AppStorage("reakMarkStyle") var readMarkStyle: ReadMarkStyle = .bar
        self.a11y_markReadType = readMarkStyle.rawValue
        
        @AppStorage("readBarThickness") var readBarThickness = 3
        self.a11y_readBarThickness = readBarThickness
        
        @AppStorage("showWebsiteIndicatorIcon") var showWebsiteIndicatorIcon = false
        self.a11y_websiteThumbnailIcon = showWebsiteIndicatorIcon
        
        @AppStorage("defaultAccountId") var defaultAccountId: Int?
        self.accounts_defaultId = defaultAccountId
        
        @AppStorage("groupAccountSort") var groupAccountSort = false
        self.accounts_grouped = groupAccountSort
        
        @AppStorage("accountSort") var accountSort: AccountSortMode = .custom
        self.accounts_sort = accountSort.rawValue
        
        @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
        self.appearance_interfaceStyle = lightOrDarkMode
        
        @AppStorage("showSettingsIcons") var showSettingsIcons = true
        self.appearance_showSettingsIcons = showSettingsIcons
        
        @AppStorage("appLock") var appLock = false
        self.behavior_biometricUnlock = appLock
        
        @AppStorage("confirmImageUploads") var confirmImageUploads = false
        self.behavior_confirmImageUploads = confirmImageUploads
        
        @AppStorage("hapticLevel") var hapticLevel: HapticPriority = .low
        self.behavior_hapticLevel = hapticLevel.rawValue
        
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        self.behavior_internetSpeed = internetSpeed.rawValue
        
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        self.behavior_upvoteOnSave = upvoteOnSave
        
        @AppStorage("collapseChildComments") var collapseChildComments = false
        self.comment_behaviors_collapseChildren = collapseChildComments
        
        @AppStorage("compactComments") var compactComments = false
        self.comment_compact = compactComments
        
        @AppStorage("defaultCommentSorting") var commentSort: CommentSortType = .top
        self.comment_defaultSort = commentSort.rawValue
        
        @AppStorage("tapCommentToCollapse") var tapCommentToCollapse = true
        self.comment_gestures_tapToCollapse = tapCommentToCollapse
        
        @AppStorage("showCommentJumpButton") var showCommentJumpButton = true
        @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing
        if showCommentJumpButton {
            self.comment_jumpButton = commentJumpButtonSide.rawValue
        } else {
            self.comment_jumpButton = "none"
        }
        
        @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment = false
        self.comment_showCreatorInstance = shouldShowUserServerInComment
        
        @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons = true
        self.community_showAvatar = shouldShowCommunityIcons
        
        @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders = true
        self.community_showBanner = shouldShowCommunityHeaders
        
        @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost = true
        self.community_showInstance = shouldShowCommunityServerInPost
        
        @AppStorage("developerMode") var developerMode = false
        self.dev_developerMode = developerMode
        
        @AppStorage("defaultFeed") var defaultFeed: DefaultFeedType = .subscribed
        self.feed_default = defaultFeed.rawValue
        
        @AppStorage("markReadOnScroll") var markReadOnScroll = false
        self.feed_markReadOnScroll = markReadOnScroll
        
        @AppStorage("showReadPosts") var showReadPosts = true
        self.feed_showRead = showReadPosts
        
        @AppStorage("showUnreadApplications") var showUnreadApplications = true
        self.inbox_badge_includeApplications = showUnreadApplications
        
        @AppStorage("showUnreadMessageReports") var showUnreadMessageReports = true
        self.inbox_badge_includeMessageReports = showUnreadMessageReports
        
        @AppStorage("showUnreadModerator") var showUnreadModerator = true
        self.inbox_badge_includeMod = showUnreadModerator
        
        @AppStorage("showUnreadPersonal") var showUnreadPersonal = true
        self.inbox_badge_includePersonal = showUnreadPersonal
        
        @AppStorage("shouldFilterRead") var shouldFilterRead = false
        self.inbox_showRead = !shouldFilterRead
        
        @AppStorage("easyTapLinkDisplayMode") var easyTapLinkDisplayMode: EasyTapLinkDisplayMode = .contextual
        self.links_displayMode = easyTapLinkDisplayMode.rawValue
        
        @AppStorage("openLinksInBrowser") var openLinksInBrowser = false
        self.links_openInBrowser = openLinksInBrowser
        
        @AppStorage("openLinksInReaderMode") var openLinksInReaderMode = false
        self.links_readerMode = openLinksInReaderMode
        
        @AppStorage("showAllModeratorActions") var showAllModeratorActions = false
        self.menus_allModActions = showAllModeratorActions
        
        @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
        self.menus_modActionGrouping = moderatorActionGrouping.rawValue
        
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        self.post_defaultSort = defaultPostSorting.rawValue
        
        @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
        self.post_fallbackSort = fallbackDefaultPostSorting.rawValue
        
        @AppStorage("limitImageHeightInFeed") var limitImageHeightInFeed = true
        self.post_limitImageHeight = limitImageHeightInFeed
        
        @AppStorage("shouldShowPostCreator") var shouldShowPostCreator = true
        self.post_showCreator = shouldShowPostCreator
        
        @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost = true
        self.post_showCreatorInstance = shouldShowUserServerInPost
        
        @AppStorage("shouldShowSubscribedStatus") var shouldShowSubscribedStatus = true
        self.post_showSubscribedStatus = shouldShowSubscribedStatus
        
        @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews = true
        self.post_showWebsitePreview = shouldShowWebsitePreviews
        
        @AppStorage("postSize") var postSize: PostSize = .large
        self.post_size = postSize.rawValue
        
        @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails = true
        @AppStorage("thumbnailsOnRight") var thumbnailsOnRight = false
        if shouldShowPostThumbnails {
            self.post_thumbnailLocation = thumbnailsOnRight ? "right" : "left"
        } else {
            self.post_thumbnailLocation = "none"
        }
        
        @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost = true
        self.post_webPreview_showHost = shouldShowWebsiteHost
        
        @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon = true
        self.post_webPreview_showIcon = shouldShowWebsiteIcon
        
        @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders = true
        self.profile_showBanner = shouldShowUserHeaders
        
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        self.safety_blurNsfw = shouldBlurNsfw ? "always" : "never"
        
        @AppStorage("showModlogWarning") var showModlogWarning = true
        self.safety_enableModlogWarning = showModlogWarning
        
        @AppStorage("allowQuickSwitcherLongPressGesture") var allowQuickSwitcherLongPressGesture = true
        self.tab_gestures_enableLongPress = allowQuickSwitcherLongPressGesture
        
        @AppStorage("allowTabBarSwipeUpGesture") var allowTabBarSwipeUpGesture = true
        self.tab_gestures_enableSwipeUp = allowTabBarSwipeUpGesture
        
        @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .nickname
        self.tab_profile_labelType = profileTabLabel.rawValue
        
        @AppStorage("showUserAvatarOnProfileTab") var showUserAvatarOnProfileTab = true
        self.tab_profile_showAvatar = showUserAvatarOnProfileTab
        
        @AppStorage("showTabNames") var showTabNames = true
        self.tab_showNames = showTabNames
        
        @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars = true
        self.person_showAvatar = shouldShowUserAvatars
    }
}
