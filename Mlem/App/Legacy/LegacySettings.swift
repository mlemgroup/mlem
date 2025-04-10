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

class LegacySettings: ObservableObject {
    @Dependency(\.persistenceRepository) var persistenceRepository
    
    public static let main: LegacySettings = .init()
    
    /// Default initializer. Will take current AppStorage values.
    init() {}

    @AppStorage("a11y.readPostIndicator") var readPostIndicator: ReadPostIndicator = .checkmark
    @AppStorage("a11y.readOutlineThickness") var readOutlineThickness: Int = 3
    @AppStorage("a11y.showSettingsIcons") var showSettingsIcons: Bool = false
    @AppStorage("a11y.websiteThumbnailIcon") var websiteThumbnailIcon: Bool = false
    @AppStorage("a11y.zoomSliderLocation") var zoomSliderLocation: ZoomSliderLocation = .none

    @AppStorage("post.size") var postSize: PostSize = .compact
    @AppStorage("post.allowMultipleColumns") var allowMultiplePostColumns: Bool = true
    @AppStorage("post.defaultSort") var defaultPostSort: ApiSortType = .hot
    @AppStorage("post.fallbackSort") var fallbackPostSort: ApiSortType = .hot
    @AppStorage("post.thumbnailLocation") var thumbnailLocation: ThumbnailLocation = .left
    @AppStorage("post.showCreator") var showPostCreator: Bool = false
    @AppStorage("post.showSubscribedStatus") var showSubscribedStatus: Bool = true
    @AppStorage("post.showDownvotesCompact") var showDownvotesCompact: Bool = false
    @AppStorage("post.gestures.tapToCollapse") var tapPostsToCollapse: Bool = true

    @AppStorage("quickSwipes.enabled") var quickSwipesEnabled: Bool = true
    
    @AppStorage("behavior.hapticLevel") var hapticLevel: HapticPriority = .low
    @AppStorage("behavior.upvoteOnSave") var upvoteOnSave: Bool = false
    @AppStorage("behavior.internetSpeed") var internetSpeed: InternetSpeed = .fast
    @AppStorage("behavior.autoplayMedia") var autoplayMedia: Bool = false
    @AppStorage("behavior.muteVideos") var muteVideos: Bool = true
    @AppStorage("behavior.confirmImageUploads") var confirmImageUploads: Bool = true
    @AppStorage("behavior.infiniteScroll") var infiniteScroll: Bool = true
    
    @AppStorage("accounts.keepPlace") var keepPlaceOnAccountSwitch: Bool = false
    @AppStorage("accounts.sort") var accountSort: AccountSortMode = .name
    @AppStorage("accounts.groupSort") var groupAccountSort: Bool = false
    
    @AppStorage("appearance.interfaceStyle") var interfaceStyle: UIUserInterfaceStyle = .unspecified
    @AppStorage("appearance.palette") var colorPalette: PaletteOption = .standard
    
    @AppStorage("markdown.wrapCodeBlockLines") var wrapCodeBlockLines: Bool = true
    
    @AppStorage("dev.developerMode") var developerMode: Bool = false
    
    @AppStorage("safety.blurNsfw") var blurNsfw: NsfwBlurBehavior = .always
    @AppStorage("safety.showNsfwCommunityWarning") var showNsfwCommunityWarning: Bool = true
    @AppStorage("safety.showModlogWarning") var showModlogWarning: Bool = true
    
    @AppStorage("privacy.autoBypassImageProxy") var autoBypassImageProxy: Bool = false
    @AppStorage("privacy.showFavicons") var showFavicons: Bool = true
    
    @AppStorage("links.openInBrowser") var openLinksInBrowser = false
    @AppStorage("links.readerMode") var openLinksInReaderMode = false
    @AppStorage("links.displayMode") var tappableLinksDisplayMode: TappableLinksDisplayMode = .contextual
    @AppStorage("links.shareMode") var linkSharingMode: LinkSharingMode = .myInstance
    @AppStorage("links.embedLoops") var embedLoops: Bool = true
    
    // swiftlint:disable:next line_length
    @AppStorage("media.animatedAvatars") var animatedAvatars: AnimatedAvatarBehavior = UIAccessibility.isReduceMotionEnabled ? .never : .always
    
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
    @AppStorage("comment.maxDepth") var maxCommentDepth: Int = 8
    @AppStorage("comment.gestures.tapToCollapse") var tapCommentsToCollapse: Bool = true
    
    @AppStorage("status.bypassImageProxyShown") var bypassImageProxyShown: Bool = false
    
    @AppStorage("tip.feedWelcomePrompt") var showFeedWelcomePrompt: Bool = true
    
    @AppStorage("navigation.sidebarVisibleByDefault") var sidebarVisibleByDefault: Bool = true
    @AppStorage("navigation.swipeAnywhere") var swipeAnywhereToNavigate: Bool = false
    
    @AppStorage("tab.profile.labelType") var tabProfileLabelType: ProfileTabLabel = .nickname
    @AppStorage("tab.profile.showAvatar") var tabProfileShowAvatar: Bool = true
    @AppStorage("tab.inbox.badgeIncludedTypes") var tabInboxBadgeIncludedTypes: Set<InboxItemType> = .all
    
    @AppStorage("menus.moderatorActionGrouping") var moderatorActionGrouping: ModeratorActionGrouping = .divider
    @AppStorage("menus.allModActions") var showAllModActions: Bool = false
    
    @AppStorage("interactionBar.alternateReportLayout") var alternateInteractionBarLayoutForReports: Bool = false
    
    @AppStorage("filters.keywordFilterEnabled") var keywordFilterEnabled: Bool = true {
        didSet {
            FiltersTracker.main.keywordFilterEnabled = keywordFilterEnabled
        }
    }
}
