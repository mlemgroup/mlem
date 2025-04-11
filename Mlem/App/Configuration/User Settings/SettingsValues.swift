//
//  SettingsValues.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-04-07.
//

import UIKit
import MlemMiddleware
import Dependencies

// swiftlint:disable line_length function_body_length file_length

/// Values backing the Settings class.
/// - Note: when adding a new settings, be sure to add relevant entries to `init`, `reinit`, and `CodingKeys`.
@Observable
class SettingsValues: Codable { // swiftlint:disable:this type_body_length
    var a11y_readPostIndicator: ReadPostIndicator
    var a11y_readOutlineThickness: Int
    var a11y_showSettingsIcons: Bool
    var a11y_websiteThumbnailIcon: Bool
    var a11y_zoomSliderLocation: ZoomSliderLocation
    var accounts_defaultId: Int?
    var accounts_grouped: Bool
    var accounts_sort: AccountSortMode
    var accounts_keepPlace: Bool
    var appearance_interfaceStyle: UIUserInterfaceStyle
    var appearance_palette: PaletteOption
    var markdown_wrapCodeBlockLines: Bool
    var behavior_biometricUnlock: Bool
    var behavior_confirmImageUploads: Bool
    var behavior_enableQuickSwipes: Bool
    var behavior_hapticLevel: HapticPriority
    var behavior_internetSpeed: InternetSpeed
    var behavior_upvoteOnSave: Bool
    var behavior_autoplayMedia: Bool
    var behavior_muteVideos: Bool
    var behavior_infiniteScroll: Bool
    var comment_behaviors_collapseChildren: Bool
    var comment_compact: Bool
    var comment_defaultSort: ApiCommentSortType
    var comment_gestures_tapToCollapse: Bool
    var comment_jumpButton: CommentJumpButtonLocation
    var comment_showCreatorInstance: Bool
    var comment_maxDepth: Int
    var community_showAvatar: Bool
    var community_showBanner: Bool
    var community_showInstance: Bool
    var dev_developerMode: Bool
    var feed_default: FeedSelection
    var feed_markReadOnScroll: Bool
    var feed_showRead: Bool
    var inbox_showRead: Bool
    var links_displayMode: TappableLinksDisplayMode
    var links_openInBrowser: Bool
    var links_readerMode: Bool
    var links_shareMode: LinkSharingMode
    var links_embedLoops: Bool
    var media_animatedAvatars: AnimatedAvatarBehavior
    var menus_allModActions: Bool
    var menus_modActionGrouping: ModeratorActionGrouping
    var post_defaultSort: ApiSortType
    var post_fallbackSort: ApiSortType
    var post_limitImageHeight: Bool
    var post_showCreator: Bool
    var post_showCreatorInstance: Bool
    var post_showSubscribedStatus: Bool
    var post_showWebsitePreview: Bool
    var post_size: PostSize
    var post_allowMultipleColumns: Bool
    var post_thumbnailLocation: ThumbnailLocation
    var post_webPreview_showHost: Bool
    var post_webPreview_showIcon: Bool
    var post_showDownvotesCompact: Bool
    var post_gestures_tapToCollapse: Bool
    var profile_showBanner: Bool
    var privacy_autoBypassImageProxy: Bool
    var privacy_showFavicons: Bool
    var safety_blurNsfw: NsfwBlurBehavior
    var safety_enableModlogWarning: Bool
    var safety_enableNsfwCommunityWarning: Bool
    var tab_gestures_enableLongPress: Bool
    var tab_gestures_enableSwipeUp: Bool
    var tab_profile_labelType: ProfileTabLabel
    var tab_profile_showAvatar: Bool
    var tab_inbox_badgeIncludedTypes: Set<InboxItemType>
    var tab_showNames: Bool
    var tip_feedWelcomePrompt: Bool
    var person_showAvatar: Bool
    var person_showInstance: Bool
    var status_bypassImageProxyShown: Bool
    var subscriptions_instanceLocation: InstanceLocation
    var subscriptions_sort: SubscriptionListSort
    var navigation_sidebarVisibleByDefault: Bool
    var navigation_swipeAnywhere: Bool
    var filters_keywordFilterEnabled: Bool
    var filters_keywords: Set<String>
    
    var interactionBar_post: PostBarConfiguration
    var interactionBar_comment: CommentBarConfiguration
    var interactionBar_reply: ReplyBarConfiguration
    var interactionBar_postReport: PostBarConfiguration
    var interactionBar_commentReport: CommentBarConfiguration
    var interactionBar_alternateReportLayout: Bool
    
    // These are included in the encoding, but are synthesized into tab_inbox_badgeIncludedTypes at decoding
    @ObservationIgnored var inbox_badge_includeApplications: Bool = false
    @ObservationIgnored var inbox_badge_includeMessageReports: Bool = false
    @ObservationIgnored var inbox_badge_includeMod: Bool = false
    @ObservationIgnored var inbox_badge_includePersonal: Bool = false
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.a11y_readPostIndicator = try container.decodeIfPresent(ReadPostIndicator.self, forKey: ._a11y_readPostIndicator) ?? .checkmark
        self.a11y_readOutlineThickness = try container.decodeIfPresent(Int.self, forKey: ._a11y_readOutlineThickness) ?? 3
        self.a11y_showSettingsIcons = try container.decodeIfPresent(Bool.self, forKey: ._a11y_showSettingsIcons) ?? true
        self.a11y_websiteThumbnailIcon = try container.decodeIfPresent(Bool.self, forKey: ._a11y_websiteThumbnailIcon) ?? false
        self.a11y_zoomSliderLocation = try container.decodeIfPresent(ZoomSliderLocation.self, forKey: ._a11y_zoomSliderLocation) ?? .none
        self.accounts_defaultId = try container.decodeIfPresent(Int?.self, forKey: ._accounts_defaultId) ?? nil
        self.accounts_grouped = try container.decodeIfPresent(Bool.self, forKey: ._accounts_grouped) ?? false
        self.accounts_sort = try container.decodeIfPresent(AccountSortMode.self, forKey: ._accounts_sort) ?? .name
        self.accounts_keepPlace = try container.decodeIfPresent(Bool.self, forKey: ._accounts_keepPlace) ?? false
        self.appearance_interfaceStyle = try container.decodeIfPresent(UIUserInterfaceStyle.self, forKey: ._appearance_interfaceStyle) ?? .unspecified
        self.appearance_palette = try container.decodeIfPresent(PaletteOption.self, forKey: ._appearance_palette) ?? .standard
        self.markdown_wrapCodeBlockLines = try container.decodeIfPresent(Bool.self, forKey: ._markdown_wrapCodeBlockLines) ?? true
        self.behavior_biometricUnlock = try container.decodeIfPresent(Bool.self, forKey: ._behavior_biometricUnlock) ?? false
        self.behavior_confirmImageUploads = try container.decodeIfPresent(Bool.self, forKey: ._behavior_confirmImageUploads) ?? true
        self.behavior_enableQuickSwipes = try container.decodeIfPresent(Bool.self, forKey: ._behavior_enableQuickSwipes) ?? true
        self.behavior_hapticLevel = try container.decodeIfPresent(HapticPriority.self, forKey: ._behavior_hapticLevel) ?? .high
        self.behavior_internetSpeed = try container.decodeIfPresent(InternetSpeed.self, forKey: ._behavior_internetSpeed) ?? .fast
        self.behavior_autoplayMedia = try container.decodeIfPresent(Bool.self, forKey: ._behavior_autoplayMedia) ?? false
        self.behavior_muteVideos = try container.decodeIfPresent(Bool.self, forKey: ._behavior_muteVideos) ?? true
        self.behavior_upvoteOnSave = try container.decodeIfPresent(Bool.self, forKey: ._behavior_upvoteOnSave) ?? false
        self.behavior_infiniteScroll = try container.decodeIfPresent(Bool.self, forKey: ._behavior_infiniteScroll) ?? true
        self.comment_behaviors_collapseChildren = try container.decodeIfPresent(Bool.self, forKey: ._comment_behaviors_collapseChildren) ?? false
        self.comment_compact = try container.decodeIfPresent(Bool.self, forKey: ._comment_compact) ?? false
        self.comment_defaultSort = try container.decodeIfPresent(ApiCommentSortType.self, forKey: ._comment_defaultSort) ?? .hot
        self.comment_gestures_tapToCollapse = try container.decodeIfPresent(Bool.self, forKey: ._comment_gestures_tapToCollapse) ?? true
        self.comment_jumpButton = try container.decodeIfPresent(CommentJumpButtonLocation.self, forKey: ._comment_jumpButton) ?? .bottomTrailing
        self.comment_showCreatorInstance = try container.decodeIfPresent(Bool.self, forKey: ._comment_showCreatorInstance) ?? true
        
        if let value = try container.decodeIfPresent(Int.self, forKey: ._comment_maxDepth) {
            self.comment_maxDepth = value
        } else if let value = try container.decodeIfPresent(Bool.self, forKey: ._comment_behaviors_collapseChildren) {
            self.comment_maxDepth = value ? 1 : 8
        } else {
            self.comment_maxDepth = 8
        }
        self.community_showAvatar = try container.decodeIfPresent(Bool.self, forKey: ._community_showAvatar) ?? true
        self.community_showBanner = try container.decodeIfPresent(Bool.self, forKey: ._community_showBanner) ?? true
        self.community_showInstance = try container.decodeIfPresent(Bool.self, forKey: ._community_showInstance) ?? true
        self.dev_developerMode = try container.decodeIfPresent(Bool.self, forKey: ._dev_developerMode) ?? false
        self.feed_default = try container.decodeIfPresent(FeedSelection.self, forKey: ._feed_default) ?? .subscribed
        self.feed_markReadOnScroll = try container.decodeIfPresent(Bool.self, forKey: ._feed_markReadOnScroll) ?? false
        self.feed_showRead = try container.decodeIfPresent(Bool.self, forKey: ._feed_showRead) ?? true
        
        if let tab_inbox_badgeIncludedTypes = try container.decodeIfPresent(Set<InboxItemType>.self, forKey: ._tab_inbox_badgeIncludedTypes) {
            self.tab_inbox_badgeIncludedTypes = tab_inbox_badgeIncludedTypes
        } else {
            let inbox_badge_includeApplications: Bool? = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeApplications)
            let inbox_badge_includeMessageReports: Bool? = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeMessageReports)
            let inbox_badge_includeMod: Bool? = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includeMod)
            let inbox_badge_includePersonal: Bool? = try container.decodeIfPresent(Bool.self, forKey: .inbox_badge_includePersonal)
            var includedTypes: Set<InboxItemType> = []
            if inbox_badge_includePersonal ?? true {
                includedTypes.formUnion([.reply, .mention, .message])
            }
            if inbox_badge_includeMod ?? true {
                includedTypes.formUnion([.postReport, .commentReport])
            }
            if inbox_badge_includeMessageReports ?? true {
                includedTypes.formUnion([.messageReport])
            }
            if inbox_badge_includeApplications ?? true {
                includedTypes.insert(.registrationApplication)
            }
            self.tab_inbox_badgeIncludedTypes = includedTypes
        }
        self.inbox_showRead = try container.decodeIfPresent(Bool.self, forKey: ._inbox_showRead) ?? true
        self.links_displayMode = try container.decodeIfPresent(TappableLinksDisplayMode.self, forKey: ._links_displayMode) ?? .contextual
        self.links_openInBrowser = try container.decodeIfPresent(Bool.self, forKey: ._links_openInBrowser) ?? false
        self.links_readerMode = try container.decodeIfPresent(Bool.self, forKey: ._links_readerMode) ?? false
        self.links_shareMode = try container.decodeIfPresent(LinkSharingMode.self, forKey: ._links_shareMode) ?? .myInstance
        self.links_embedLoops = try container.decodeIfPresent(Bool.self, forKey: ._links_embedLoops) ?? true
        self.media_animatedAvatars = try container.decodeIfPresent(AnimatedAvatarBehavior.self, forKey: ._media_animatedAvatars) ?? (UIAccessibility.isReduceMotionEnabled ? .never : .always)
        self.menus_allModActions = try container.decodeIfPresent(Bool.self, forKey: ._menus_allModActions) ?? false
        self.menus_modActionGrouping = try container.decodeIfPresent(ModeratorActionGrouping.self, forKey: ._menus_modActionGrouping) ?? .divider
        self.post_defaultSort = try container.decodeIfPresent(ApiSortType.self, forKey: ._post_defaultSort) ?? .hot
        self.post_fallbackSort = try container.decodeIfPresent(ApiSortType.self, forKey: ._post_fallbackSort) ?? .hot
        self.post_limitImageHeight = try container.decodeIfPresent(Bool.self, forKey: ._post_limitImageHeight) ?? true
        self.post_showCreator = try container.decodeIfPresent(Bool.self, forKey: ._post_showCreator) ?? true
        self.post_showCreatorInstance = try container.decodeIfPresent(Bool.self, forKey: ._post_showCreatorInstance) ?? true
        self.post_showSubscribedStatus = try container.decodeIfPresent(Bool.self, forKey: ._post_showSubscribedStatus) ?? false
        self.post_showWebsitePreview = try container.decodeIfPresent(Bool.self, forKey: ._post_showWebsitePreview) ?? true
        self.post_showDownvotesCompact = try container.decodeIfPresent(Bool.self, forKey: ._post_showDownvotesCompact) ?? false
        self.post_size = try container.decodeIfPresent(PostSize.self, forKey: ._post_size) ?? .large
        self.post_allowMultipleColumns = try container.decodeIfPresent(Bool.self, forKey: ._post_allowMultipleColumns) ?? true
        self.post_thumbnailLocation = try container.decodeIfPresent(ThumbnailLocation.self, forKey: ._post_thumbnailLocation) ?? .left
        self.post_webPreview_showHost = try container.decodeIfPresent(Bool.self, forKey: ._post_webPreview_showHost) ?? true
        self.post_webPreview_showIcon = try container.decodeIfPresent(Bool.self, forKey: ._post_webPreview_showIcon) ?? true
        self.post_gestures_tapToCollapse = try container.decodeIfPresent(Bool.self, forKey: ._post_gestures_tapToCollapse) ?? true
        self.privacy_autoBypassImageProxy = try container.decodeIfPresent(Bool.self, forKey: ._privacy_autoBypassImageProxy) ?? false
        self.privacy_showFavicons = try container.decodeIfPresent(Bool.self, forKey: ._privacy_showFavicons) ?? true
        self.profile_showBanner = try container.decodeIfPresent(Bool.self, forKey: ._profile_showBanner) ?? true
        self.safety_blurNsfw = try container.decodeIfPresent(NsfwBlurBehavior.self, forKey: ._safety_blurNsfw) ?? .always
        self.safety_enableModlogWarning = try container.decodeIfPresent(Bool.self, forKey: ._safety_enableModlogWarning) ?? true
        self.safety_enableNsfwCommunityWarning = try container.decodeIfPresent(Bool.self, forKey: ._safety_enableNsfwCommunityWarning) ?? true
        self.tab_gestures_enableLongPress = try container.decodeIfPresent(Bool.self, forKey: ._tab_gestures_enableLongPress) ?? true
        self.tab_gestures_enableSwipeUp = try container.decodeIfPresent(Bool.self, forKey: ._tab_gestures_enableSwipeUp) ?? true
        self.tab_profile_labelType = try container.decodeIfPresent(ProfileTabLabel.self, forKey: ._tab_profile_labelType) ?? .nickname
        self.tab_profile_showAvatar = try container.decodeIfPresent(Bool.self, forKey: ._tab_profile_showAvatar) ?? true
        self.tab_showNames = try container.decodeIfPresent(Bool.self, forKey: ._tab_showNames) ?? true
        self.tip_feedWelcomePrompt = try container.decodeIfPresent(Bool.self, forKey: ._tip_feedWelcomePrompt) ?? true
        self.person_showAvatar = try container.decodeIfPresent(Bool.self, forKey: ._person_showAvatar) ?? true
        self.person_showInstance = try container.decodeIfPresent(Bool.self, forKey: ._person_showInstance) ?? true
        self.status_bypassImageProxyShown = try container.decodeIfPresent(Bool.self, forKey: ._status_bypassImageProxyShown) ?? false
        self.subscriptions_instanceLocation = try container.decodeIfPresent(InstanceLocation.self, forKey: ._subscriptions_instanceLocation) ?? (UIDevice.isPad ? .bottom : .trailing)
        self.subscriptions_sort = try container.decodeIfPresent(SubscriptionListSort.self, forKey: ._subscriptions_sort) ?? .alphabetical
        self.navigation_sidebarVisibleByDefault = try container.decodeIfPresent(Bool.self, forKey: ._navigation_sidebarVisibleByDefault) ?? true
        self.navigation_swipeAnywhere = try container.decodeIfPresent(Bool.self, forKey: ._navigation_swipeAnywhere) ?? false
        self.filters_keywordFilterEnabled = try container.decodeIfPresent(Bool.self, forKey: ._filters_keywordFilterEnabled) ?? true
        self.filters_keywords = try container.decodeIfPresent(Set<String>.self, forKey: ._filters_keywords) ?? .init()
        self.interactionBar_post = try container.decodeIfPresent(PostBarConfiguration.self, forKey: ._interactionBar_post) ?? .default
        self.interactionBar_comment = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: ._interactionBar_comment) ?? .default
        self.interactionBar_reply = try container.decodeIfPresent(ReplyBarConfiguration.self, forKey: ._interactionBar_reply) ?? .default
        self.interactionBar_postReport = try container.decodeIfPresent(PostBarConfiguration.self, forKey: ._interactionBar_postReport) ?? .reportDefault_
        self.interactionBar_commentReport = try container.decodeIfPresent(CommentBarConfiguration.self, forKey: ._interactionBar_commentReport) ?? .reportDefault_
        self.interactionBar_alternateReportLayout = try container.decodeIfPresent(Bool.self, forKey: ._interactionBar_alternateReportLayout) ?? false
    }
    
    func reinit(from otherValues: SettingsValues) {
        self.a11y_readPostIndicator = otherValues.a11y_readPostIndicator
        self.a11y_readOutlineThickness = otherValues.a11y_readOutlineThickness
        self.a11y_showSettingsIcons = otherValues.a11y_showSettingsIcons
        self.a11y_websiteThumbnailIcon = otherValues.a11y_websiteThumbnailIcon
        self.a11y_zoomSliderLocation = otherValues.a11y_zoomSliderLocation
        self.accounts_defaultId = otherValues.accounts_defaultId
        self.accounts_grouped = otherValues.accounts_grouped
        self.accounts_sort = otherValues.accounts_sort
        self.accounts_keepPlace = otherValues.accounts_keepPlace
        self.appearance_interfaceStyle = otherValues.appearance_interfaceStyle
        self.appearance_palette = otherValues.appearance_palette
        self.markdown_wrapCodeBlockLines = otherValues.markdown_wrapCodeBlockLines
        self.behavior_biometricUnlock = otherValues.behavior_biometricUnlock
        self.behavior_confirmImageUploads = otherValues.behavior_confirmImageUploads
        self.behavior_enableQuickSwipes = otherValues.behavior_enableQuickSwipes
        self.behavior_hapticLevel = otherValues.behavior_hapticLevel
        self.behavior_internetSpeed = otherValues.behavior_internetSpeed
        self.behavior_upvoteOnSave = otherValues.behavior_upvoteOnSave
        self.behavior_autoplayMedia = otherValues.behavior_autoplayMedia
        self.behavior_muteVideos = otherValues.behavior_muteVideos
        self.behavior_infiniteScroll = otherValues.behavior_infiniteScroll
        self.comment_behaviors_collapseChildren = otherValues.comment_behaviors_collapseChildren
        self.comment_compact = otherValues.comment_compact
        self.comment_defaultSort = otherValues.comment_defaultSort
        self.comment_gestures_tapToCollapse = otherValues.comment_gestures_tapToCollapse
        self.comment_jumpButton = otherValues.comment_jumpButton
        self.comment_showCreatorInstance = otherValues.comment_showCreatorInstance
        self.comment_maxDepth = otherValues.comment_maxDepth
        self.community_showAvatar = otherValues.community_showAvatar
        self.community_showBanner = otherValues.community_showBanner
        self.community_showInstance = otherValues.community_showInstance
        self.dev_developerMode = otherValues.dev_developerMode
        self.feed_default = otherValues.feed_default
        self.feed_markReadOnScroll = otherValues.feed_markReadOnScroll
        self.feed_showRead = otherValues.feed_showRead
        self.inbox_showRead = otherValues.inbox_showRead
        self.links_displayMode = otherValues.links_displayMode
        self.links_openInBrowser = otherValues.links_openInBrowser
        self.links_readerMode = otherValues.links_readerMode
        self.links_shareMode = otherValues.links_shareMode
        self.links_embedLoops = otherValues.links_embedLoops
        self.media_animatedAvatars = otherValues.media_animatedAvatars
        self.menus_allModActions = otherValues.menus_allModActions
        self.menus_modActionGrouping = otherValues.menus_modActionGrouping
        self.post_defaultSort = otherValues.post_defaultSort
        self.post_fallbackSort = otherValues.post_fallbackSort
        self.post_limitImageHeight = otherValues.post_limitImageHeight
        self.post_showCreator = otherValues.post_showCreator
        self.post_showCreatorInstance = otherValues.post_showCreatorInstance
        self.post_showSubscribedStatus = otherValues.post_showSubscribedStatus
        self.post_showWebsitePreview = otherValues.post_showWebsitePreview
        self.post_size = otherValues.post_size
        self.post_allowMultipleColumns = otherValues.post_allowMultipleColumns
        self.post_thumbnailLocation = otherValues.post_thumbnailLocation
        self.post_webPreview_showHost = otherValues.post_webPreview_showHost
        self.post_webPreview_showIcon = otherValues.post_webPreview_showIcon
        self.post_showDownvotesCompact = otherValues.post_showDownvotesCompact
        self.post_gestures_tapToCollapse = otherValues.post_gestures_tapToCollapse
        self.profile_showBanner = otherValues.profile_showBanner
        self.privacy_autoBypassImageProxy = otherValues.privacy_autoBypassImageProxy
        self.privacy_showFavicons = otherValues.privacy_showFavicons
        self.safety_blurNsfw = otherValues.safety_blurNsfw
        self.safety_enableModlogWarning = otherValues.safety_enableModlogWarning
        self.safety_enableNsfwCommunityWarning = otherValues.safety_enableNsfwCommunityWarning
        self.tab_gestures_enableLongPress = otherValues.tab_gestures_enableLongPress
        self.tab_gestures_enableSwipeUp = otherValues.tab_gestures_enableSwipeUp
        self.tab_profile_labelType = otherValues.tab_profile_labelType
        self.tab_profile_showAvatar = otherValues.tab_profile_showAvatar
        self.tab_inbox_badgeIncludedTypes = otherValues.tab_inbox_badgeIncludedTypes
        self.tab_showNames = otherValues.tab_showNames
        self.tip_feedWelcomePrompt = otherValues.tip_feedWelcomePrompt
        self.person_showAvatar = otherValues.person_showAvatar
        self.person_showInstance = otherValues.person_showInstance
        self.status_bypassImageProxyShown = otherValues.status_bypassImageProxyShown
        self.subscriptions_instanceLocation = otherValues.subscriptions_instanceLocation
        self.subscriptions_sort = otherValues.subscriptions_sort
        self.navigation_sidebarVisibleByDefault = otherValues.navigation_sidebarVisibleByDefault
        self.navigation_swipeAnywhere = otherValues.navigation_swipeAnywhere
        self.filters_keywordFilterEnabled = otherValues.filters_keywordFilterEnabled
        self.filters_keywords = otherValues.filters_keywords
        self.interactionBar_post = otherValues.interactionBar_post
        self.interactionBar_comment = otherValues.interactionBar_comment
        self.interactionBar_reply = otherValues.interactionBar_reply
        self.interactionBar_postReport = otherValues.interactionBar_postReport
        self.interactionBar_commentReport = otherValues.interactionBar_commentReport
        self.interactionBar_alternateReportLayout = otherValues.interactionBar_alternateReportLayout
        self.inbox_badge_includeApplications = otherValues.inbox_badge_includeApplications
        self.inbox_badge_includeMessageReports = otherValues.inbox_badge_includeMessageReports
        self.inbox_badge_includeMod = otherValues.inbox_badge_includeMod
        self.inbox_badge_includePersonal = otherValues.inbox_badge_includePersonal
    }
    
    enum CodingKeys: String, CodingKey {
        case _a11y_readPostIndicator = "a11y_readPostIndicator"
        case _a11y_readOutlineThickness = "a11y_readOutlineThickness"
        case _a11y_showSettingsIcons = "a11y_showSettingsIcons"
        case _a11y_websiteThumbnailIcon = "a11y_websiteThumbnailIcon"
        case _a11y_zoomSliderLocation = "a11y_zoomSliderLocation"
        case _accounts_defaultId = "accounts_defaultId"
        case _accounts_grouped = "accounts_grouped"
        case _accounts_sort = "accounts_sort"
        case _accounts_keepPlace = "accounts_keepPlace"
        case _appearance_interfaceStyle = "appearance_interfaceStyle"
        case _appearance_palette = "appearance_palette"
        case _markdown_wrapCodeBlockLines = "markdown_wrapCodeBlockLines"
        case _behavior_biometricUnlock = "behavior_biometricUnlock"
        case _behavior_confirmImageUploads = "behavior_confirmImageUploads"
        case _behavior_enableQuickSwipes = "behavior_enableQuickSwipes"
        case _behavior_hapticLevel = "behavior_hapticLevel"
        case _behavior_internetSpeed = "behavior_internetSpeed"
        case _behavior_upvoteOnSave = "behavior_upvoteOnSave"
        case _behavior_autoplayMedia = "behavior_autoplayMedia"
        case _behavior_muteVideos = "behavior_muteVideos"
        case _behavior_infiniteScroll = "behavior_infiniteScroll"
        case _comment_behaviors_collapseChildren = "comment_behaviors_collapseChildren"
        case _comment_compact = "comment_compact"
        case _comment_defaultSort = "comment_defaultSort"
        case _comment_gestures_tapToCollapse = "comment_gestures_tapToCollapse"
        case _comment_jumpButton = "comment_jumpButton"
        case _comment_showCreatorInstance = "comment_showCreatorInstance"
        case _comment_maxDepth = "comment_maxDepth"
        case _community_showAvatar = "community_showAvatar"
        case _community_showBanner = "community_showBanner"
        case _community_showInstance = "community_showInstance"
        case _dev_developerMode = "dev_developerMode"
        case _feed_default = "feed_default"
        case _feed_markReadOnScroll = "feed_markReadOnScroll"
        case _feed_showRead = "feed_showRead"
        case _inbox_showRead = "inbox_showRead"
        case _links_displayMode = "links_displayMode"
        case _links_openInBrowser = "links_openInBrowser"
        case _links_readerMode = "links_readerMode"
        case _links_shareMode = "links_shareMode"
        case _links_embedLoops = "links_embedLoops"
        case _media_animatedAvatars = "media_animatedAvatars"
        case _menus_allModActions = "menus_allModActions"
        case _menus_modActionGrouping = "menus_modActionGrouping"
        case _post_defaultSort = "post_defaultSort"
        case _post_fallbackSort = "post_fallbackSort"
        case _post_limitImageHeight = "post_limitImageHeight"
        case _post_showCreator = "post_showCreator"
        case _post_showCreatorInstance = "post_showCreatorInstance"
        case _post_showSubscribedStatus = "post_showSubscribedStatus"
        case _post_showWebsitePreview = "post_showWebsitePreview"
        case _post_size = "post_size"
        case _post_allowMultipleColumns = "post_allowMultipleColumns"
        case _post_thumbnailLocation = "post_thumbnailLocation"
        case _post_webPreview_showHost = "post_webPreview_showHost"
        case _post_webPreview_showIcon = "post_webPreview_showIcon"
        case _post_showDownvotesCompact = "post_showDownvotesCompact"
        case _post_gestures_tapToCollapse = "post_gestures_tapToCollapse"
        case _profile_showBanner = "profile_showBanner"
        case _privacy_autoBypassImageProxy = "privacy_autoBypassImageProxy"
        case _privacy_showFavicons = "privacy_showFavicons"
        case _safety_blurNsfw = "safety_blurNsfw"
        case _safety_enableModlogWarning = "safety_enableModlogWarning"
        case _safety_enableNsfwCommunityWarning = "safety_enableNsfwCommunityWarning"
        case _tab_gestures_enableLongPress = "tab_gestures_enableLongPress"
        case _tab_gestures_enableSwipeUp = "tab_gestures_enableSwipeUp"
        case _tab_profile_labelType = "tab_profile_labelType"
        case _tab_profile_showAvatar = "tab_profile_showAvatar"
        case _tab_inbox_badgeIncludedTypes = "tab_inbox_badgeIncludedTypes"
        case _tab_showNames = "tab_showNames"
        case _tip_feedWelcomePrompt = "tip_feedWelcomePrompt"
        case _person_showAvatar = "person_showAvatar"
        case _person_showInstance = "person_showInstance"
        case _status_bypassImageProxyShown = "status_bypassImageProxyShown"
        case _subscriptions_instanceLocation = "subscriptions_instanceLocation"
        case _subscriptions_sort = "subscriptions_sort"
        case _navigation_sidebarVisibleByDefault = "navigation_sidebarVisibleByDefault"
        case _navigation_swipeAnywhere = "navigation_swipeAnywhere"
        case _filters_keywordFilterEnabled = "filters_keywordFilterEnabled"
        case _filters_keywords = "filters_keywords"
        case _interactionBar_post = "interactionBar_post"
        case _interactionBar_comment = "interactionBar_comment"
        case _interactionBar_reply = "interactionBar_reply"
        case _interactionBar_postReport = "interactionBar_postReport"
        case _interactionBar_commentReport = "interactionBar_commentReport"
        case _interactionBar_alternateReportLayout = "interactionBar_alternateReportLayout"
        case inbox_badge_includeApplications = "inbox_badge_includeApplications"
        case inbox_badge_includeMessageReports = "inbox_badge_includeMessageReports"
        case inbox_badge_includeMod = "inbox_badge_includeMod"
        case inbox_badge_includePersonal = "inbox_badge_includePersonal"
    }
    
    init(from settings: LegacySettings, filteredKeywords: Set<String>) {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        self.a11y_readPostIndicator = settings.readPostIndicator
        self.a11y_readOutlineThickness = settings.readOutlineThickness
        self.a11y_showSettingsIcons = settings.showSettingsIcons
        self.a11y_websiteThumbnailIcon = settings.websiteThumbnailIcon
        self.a11y_zoomSliderLocation = settings.zoomSliderLocation
        self.accounts_defaultId = nil // In 2.0, the last used account is now activated when the app is opened
        self.accounts_grouped = settings.groupAccountSort
        self.accounts_sort = settings.accountSort
        self.accounts_keepPlace = settings.keepPlaceOnAccountSwitch
        self.appearance_interfaceStyle = settings.interfaceStyle
        self.appearance_palette = settings.colorPalette
        self.markdown_wrapCodeBlockLines = settings.wrapCodeBlockLines
        self.behavior_biometricUnlock = false // Removed in 2.0
        self.behavior_confirmImageUploads = settings.confirmImageUploads
        self.behavior_enableQuickSwipes = settings.quickSwipesEnabled
        self.behavior_hapticLevel = settings.hapticLevel
        self.behavior_internetSpeed = settings.internetSpeed
        self.behavior_upvoteOnSave = settings.upvoteOnSave
        self.behavior_autoplayMedia = settings.autoplayMedia
        self.behavior_muteVideos = settings.muteVideos
        self.behavior_infiniteScroll = settings.infiniteScroll
        self.comment_behaviors_collapseChildren = false // Replaced by comment_maxDepth in 2.0
        self.comment_compact = settings.compactComments
        self.comment_defaultSort = settings.commentSort
        self.comment_gestures_tapToCollapse = settings.tapCommentsToCollapse
        self.comment_jumpButton = settings.jumpButton
        self.comment_showCreatorInstance = true // Removed in 2.0
        self.comment_maxDepth = settings.maxCommentDepth
        self.community_showAvatar = settings.showCommunityAvatar
        self.community_showBanner = true // Removed in 2.0
        self.community_showInstance = true // Removed in 2.0
        self.dev_developerMode = settings.developerMode
        self.feed_default = settings.defaultFeed
        self.feed_markReadOnScroll = settings.markReadOnScroll
        self.feed_showRead = settings.showReadInFeed
        self.inbox_showRead = settings.showReadInInbox
        self.links_displayMode = settings.tappableLinksDisplayMode
        self.links_openInBrowser = settings.openLinksInBrowser
        self.links_readerMode = settings.openLinksInReaderMode
        self.links_shareMode = settings.linkSharingMode
        self.links_embedLoops = settings.embedLoops
        self.media_animatedAvatars = settings.animatedAvatars
        self.menus_allModActions = settings.showAllModActions
        self.menus_modActionGrouping = settings.moderatorActionGrouping
        self.post_defaultSort = settings.defaultPostSort
        self.post_fallbackSort = settings.fallbackPostSort
        self.post_limitImageHeight = true // Removed in 2.0
        self.post_showCreator = settings.showPostCreator
        self.post_showCreatorInstance = true // Removed in 2.0
        self.post_showSubscribedStatus = settings.showSubscribedStatus
        self.post_showWebsitePreview = true // Removed in 2.0
        self.post_size = settings.postSize
        self.post_allowMultipleColumns = settings.allowMultiplePostColumns
        self.post_thumbnailLocation = settings.thumbnailLocation
        self.post_webPreview_showHost = true // Removed in 2.0
        self.post_webPreview_showIcon = settings.showFavicons
        self.post_showDownvotesCompact = settings.showDownvotesCompact
        self.post_gestures_tapToCollapse = true
        self.profile_showBanner = true // Removed in 2.0
        self.safety_blurNsfw = settings.blurNsfw
        self.safety_enableNsfwCommunityWarning = settings.showNsfwCommunityWarning
        self.safety_enableModlogWarning = settings.showModlogWarning
        self.tab_gestures_enableLongPress = true // Removed in 2.0
        self.tab_gestures_enableSwipeUp = true // Removed in 2.0
        self.tab_profile_labelType = settings.tabProfileLabelType
        self.tab_profile_showAvatar = settings.tabProfileShowAvatar
        self.tab_inbox_badgeIncludedTypes = settings.tabInboxBadgeIncludedTypes
        self.tab_showNames = true // Removed in 2.0
        self.tip_feedWelcomePrompt = settings.showFeedWelcomePrompt
        self.person_showAvatar = settings.showPersonAvatar
        self.person_showInstance = true // Removed in 2.0
        self.privacy_autoBypassImageProxy = settings.autoBypassImageProxy
        self.privacy_showFavicons = settings.showFavicons // TODO: unused?
        self.status_bypassImageProxyShown = settings.bypassImageProxyShown
        self.subscriptions_instanceLocation = settings.subscriptionInstanceLocation
        self.subscriptions_sort = settings.subscriptionSort
        self.navigation_sidebarVisibleByDefault = settings.sidebarVisibleByDefault
        self.navigation_swipeAnywhere = settings.swipeAnywhereToNavigate
        self.filters_keywordFilterEnabled = settings.keywordFilterEnabled
        self.filters_keywords = filteredKeywords
        self.interactionBar_alternateReportLayout = settings.alternateInteractionBarLayoutForReports
        
        let interactionBarConfigurations = persistenceRepository.loadInteractionBarConfigurations()
        self.interactionBar_post = interactionBarConfigurations.post
        self.interactionBar_comment = interactionBarConfigurations.comment
        self.interactionBar_reply = interactionBarConfigurations.reply
        self.interactionBar_postReport = interactionBarConfigurations.postReport
        self.interactionBar_commentReport = interactionBarConfigurations.commentReport
    }
}

// swiftlint:enable line_length function_body_length file_length
