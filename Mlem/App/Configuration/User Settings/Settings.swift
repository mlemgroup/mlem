//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

// swiftlint:disable file_length

import Foundation
import MlemMiddleware
import UIKit
import Dependencies
import SwiftUI
//
// @propertyWrapper
// struct Setting<T>: DynamicProperty {
//    @State private var defaults: SettingsValues = Settings.main.values
//    private let keyPath: ReferenceWritableKeyPath<SettingsValues, T>
//    
//    public init(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>) {
//        self.keyPath = keyPath
//    }
//
//    public var wrappedValue: T {
//        get { defaults[keyPath: keyPath] }
//        nonmutating set {
//            defaults[keyPath: keyPath] = newValue
//            Settings.main._save()
//        }
//    }
//
//    public var projectedValue: Binding<T> {
//        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
//    }
// }

/// Responsible for managing settings logic.
///
/// There should only ever be one instance of this class, the private `main`. To enforce this, interaction with the class
/// is entirely abstracted to behind a static API.
///
/// To access a settings value, it is recommended to use the `@Setting` property wrapper. In contexts where this is not available,
/// use `Settings.get(\.keypath)`.
class Settings {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    fileprivate var values: SettingsValues
    fileprivate static let main: Settings = .init()
    
    // MARK: - API
    
    static func get<T>(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>) -> T {
        main.values[keyPath: keyPath]
    }
    
    static func set<T>(_ keyPath: ReferenceWritableKeyPath<SettingsValues, T>, to newValue: T) {
        main.values[keyPath: keyPath] = newValue
        main._save()
    }
    
    static func save(to systemSetting: SystemSetting) async {
        await main._save(to: systemSetting)
    }
    
    @MainActor
    static func restore(from systemSetting: SystemSetting) {
        main._restore(from: systemSetting)
    }
    
    @MainActor
    static func reinit(with values: SettingsValues) {
        main._reinit(with: values)
    }
    
    static func encoded() throws -> Data {
        try JSONEncoder().encode(main.values)
    }
    
    // MARK: - Logic
    
    fileprivate func _save() {
        Task {
            try await persistenceRepository.saveSystemSettings(values, setting: .v2_system)
        }
    }
    
    private func _save(to systemSetting: SystemSetting) async {
        do {
            try await persistenceRepository.saveSystemSettings(values, setting: systemSetting)
            ToastModel.main.add(.success("Saved Settings"))
        } catch {
            handleError(error)
        }
    }
    
    @MainActor
    private func _restore(from systemSetting: SystemSetting) {
        if let savedSettings = persistenceRepository.loadSystemSettings(systemSetting) {
            // values = savedSettings
            values.behavior_upvoteOnSave = savedSettings.behavior_upvoteOnSave
            _save()
            ToastModel.main.add(.success("Restored Settings"))
        } else {
            ToastModel.main.add(.failure("Could not find settings"))
        }
    }
    
    @MainActor
    private func _reinit(with newValues: SettingsValues) {
        // values = newValues
        values.behavior_upvoteOnSave = newValues.behavior_upvoteOnSave
        _save()
    }
    
    private init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        if let savedSettings = persistenceRepository.loadSystemSettings(.v2_system) {
            values = savedSettings
        } else {
            values = .init(from: .main, filteredKeywords: .init()) // TODO: NOW
            Task {
                do {
                    try await persistenceRepository.saveSystemSettings(values, setting: .v2_system)
                } catch {
                    handleError(error)
                }
            }
        }
    }
}

/// Values backing the Settings class.
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
    var filters_keywordFilterEnabled: Bool // TODO: update FiltersTracker.main
    var interactionBar_alternateReportLayout: Bool
    
    // These are included in the encoding, but are synthesized into tab_inbox_badgeIncludedTypes at decoding
    @ObservationIgnored var inbox_badge_includeApplications: Bool = false
    @ObservationIgnored var inbox_badge_includeMessageReports: Bool = false
    @ObservationIgnored var inbox_badge_includeMod: Bool = false
    @ObservationIgnored var inbox_badge_includePersonal: Bool = false
    
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
        case _interactionBar_alternateReportLayout = "interactionBar_alternateReportLayout"
     
        case inbox_badge_includeApplications = "inbox_badge_includeApplications"
        case inbox_badge_includeMessageReports = "inbox_badge_includeMessageReports"
        case inbox_badge_includeMod = "inbox_badge_includeMod"
        case inbox_badge_includePersonal = "inbox_badge_includePersonal"
    }
    
    // MARK: Settings saved in files
    
    var filteredKeywords: Set<String>
    
    // swiftlint:disable line_length function_body_length
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
        self.filteredKeywords = .init() // TODO: NOW // try container.decodeIfPresent(Set<String>.self, forKey: ._filteredKeywords) ?? .init()
        self.interactionBar_alternateReportLayout = try container.decodeIfPresent(Bool.self, forKey: ._interactionBar_alternateReportLayout) ?? false
    }
    
    // swiftlint:enable line_length
    
    init(from settings: LegacySettings, filteredKeywords: Set<String>) {
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
        
        self.filteredKeywords = filteredKeywords
        self.interactionBar_alternateReportLayout = settings.alternateInteractionBarLayoutForReports
    }
    // swiftlint:enable function_body_length
}

// swiftlint:enable file_length
