//
//  Settings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-07.
//  Adapted from https://fatbobman.com/en/posts/appstorage/
//

import Dependencies
import MlemMiddleware
import SwiftUI

class Settings: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    public static let main: Settings = .init()
    
    /// Default initializer. Will take current AppStorage values.
    init() {}

    @AppStorage("post.size") var postSize: PostSize = .compact
    @AppStorage("post.defaultSort") var defaultPostSort: ApiSortType = .hot
    @AppStorage("post.fallbackSort") var fallbackPostSort: ApiSortType = .hot
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    @AppStorage("post.showCreator") var showPostCreator: Bool = false
    
    @AppStorage("quickSwipes.enabled") var quickSwipesEnabled: Bool = true
    
    @AppStorage("behavior.hapticLevel") var hapticLevel: HapticPriority = .low
    @AppStorage("behavior.upvoteOnSave") var upvoteOnSave: Bool = false
    @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("behavior.autoplayMedia") var autoplayMedia: Bool = false
    
    @AppStorage("accounts.keepPlace") var keepPlaceOnAccountSwitch: Bool = false
    @AppStorage("accounts.sort") var accountSort: AccountSortMode = .name
    @AppStorage("accounts.groupSort") var groupAccountSort: Bool = false
    
    @AppStorage("appearance.interfaceStyle") var interfaceStyle: UIUserInterfaceStyle = .unspecified
    @AppStorage("appearance.palette") var colorPalette: PaletteOption = .standard
    
    @AppStorage("markdown.wrapCodeBlockLines") var wrapCodeBlockLines: Bool = true
    
    @AppStorage("dev.developerMode") var developerMode: Bool = false
    
    @AppStorage("safety.blurNsfw") var blurNsfw: NsfwBlurBehavior = .always
    @AppStorage("safety.showNsfwCommunityWarning") var showNsfwCommunityWarning: Bool = true
    
    @AppStorage("privacy.autoBypassImageProxy") var autoBypassImageProxy: Bool = false
    
    @AppStorage("links.openInBrowser") var openLinksInBrowser = false
    @AppStorage("links.readerMode") var openLinksInReaderMode = false
    @AppStorage("links.displayMode") var tappableLinksDisplayMode: TappableLinksDisplayMode = .contextual
    
    @AppStorage("feed.markReadOnScroll") var markReadOnScroll: Bool = false
    @AppStorage("feed.showRead") var showReadInFeed: Bool = true
    @AppStorage("feed.default") var defaultFeed: FeedSelection = .subscribed
    
    @AppStorage("inbox.showRead") var showReadInInbox: Bool = true
    
    @AppStorage("subscriptions.instanceLocation") var subscriptionInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    @AppStorage("subscriptions.sort") var subscriptionSort: SubscriptionListSort = .alphabetical
    
    @AppStorage("person.showAvatar") var showPersonAvatar: Bool = true
    
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
    @AppStorage("comment.compact") var compactComments: Bool = false
    @AppStorage("comment.jumpButton") var jumpButton: CommentJumpButtonLocation = .bottomTrailing
    @AppStorage("comment.sort") var commentSort: ApiCommentSortType = .top
    
    @AppStorage("status.bypassImageProxyShown") var bypassImageProxyShown: Bool = false
    
    @AppStorage("tip.feedWelcomePrompt") var showFeedWelcomePrompt: Bool = true
    
    @AppStorage("navigation.sidebarVisibleByDefault") var sidebarVisibleByDefault: Bool = true
    
    @AppStorage("menus.moderatorActionGrouping") var moderatorActionGrouping: ModeratorActionGrouping = .divider
    
    var codable: CodableSettings { .init(from: self) }
    
    @MainActor
    func restore(from systemSetting: SystemSetting) {
        if let savedSettings = persistenceRepository.loadSystemSettings(systemSetting) {
            reinit(from: savedSettings)
            ToastModel.main.add(.success("Restored Settings"))
        } else {
            ToastModel.main.add(.failure("Could not find settings"))
        }
    }
    
    func save(to systemSetting: SystemSetting) async {
        do {
            try await persistenceRepository.saveSystemSettings(codable, setting: systemSetting)
            ToastModel.main.add(.success("Saved Settings"))
        } catch {
            handleError(error)
        }
    }
    
    /// Re-initializes all values from the given CodableSettings object.
    @MainActor
    func reinit(from settings: CodableSettings) {
        postSize = settings.post_size
        defaultPostSort = settings.post_defaultSort
        fallbackPostSort = settings.post_fallbackSort
        thumbnailLocation = settings.post_thumbnailLocation
        showPostCreator = settings.post_showCreator
        quickSwipesEnabled = settings.behavior_enableQuickSwipes
        hapticLevel = settings.behavior_hapticLevel
        upvoteOnSave = settings.behavior_upvoteOnSave
        internetSpeed = settings.behavior_internetSpeed
        keepPlaceOnAccountSwitch = settings.accounts_keepPlace
        accountSort = settings.accounts_sort
        groupAccountSort = settings.accounts_grouped
        interfaceStyle = settings.appearance_interfaceStyle
        colorPalette = settings.appearance_palette
        wrapCodeBlockLines = settings.markdown_wrapCodeBlockLines
        developerMode = settings.dev_developerMode
        blurNsfw = settings.safety_blurNsfw
        showNsfwCommunityWarning = settings.safety_enableNsfwCommunityWarning
        openLinksInBrowser = settings.links_openInBrowser
        openLinksInReaderMode = settings.links_readerMode
        tappableLinksDisplayMode = settings.links_tappableLinksDisplayMode
        markReadOnScroll = settings.feed_markReadOnScroll
        showReadInFeed = settings.feed_showRead
        defaultFeed = settings.feed_default
        showReadInInbox = settings.inbox_showRead
        subscriptionInstanceLocation = settings.subscriptions_instanceLocation
        subscriptionSort = settings.subscriptions_sort
        showPersonAvatar = settings.person_showAvatar
        showCommunityAvatar = settings.community_showAvatar
        compactComments = settings.comment_compact
        jumpButton = settings.comment_jumpButton
        commentSort = settings.comment_defaultSort
        bypassImageProxyShown = settings.status_bypassImageProxyShown
        autoBypassImageProxy = settings.privacy_autoBypassImageProxy
        sidebarVisibleByDefault = settings.navigation_sidebarVisibleByDefault
    }
}
