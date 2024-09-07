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

class Settings: ObservableObject, Codable {
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
    
    @AppStorage("accounts.keepPlace") var keepPlaceOnAccountSwitch: Bool = false
    @AppStorage("accounts.sort") var accountSort: AccountSortMode = .name
    @AppStorage("accounts.groupSort") var groupAccountSort: Bool = false
    
    @AppStorage("appearance.interfaceStyle") var interfaceStyle: UIUserInterfaceStyle = .unspecified
    @AppStorage("appearance.palette") var colorPalette: PaletteOption = .standard
    
    @AppStorage("dev.developerMode") var developerMode: Bool = false
    
    @AppStorage("safety.blurNsfw") var blurNsfw: NsfwBlurBehavior = .always
    @AppStorage("safety.showNsfwCommunityWarning") var showNsfwCommunityWarning: Bool = true
    
    @AppStorage("links.openInBrowser") var openLinksInBrowser: Bool = false
    @AppStorage("links.readerMode") var openLinksInReaderMode: Bool = false
    
    @AppStorage("feed.markReadOnScroll") var markReadOnScroll: Bool = false
    @AppStorage("feed.showRead") var showReadInFeed: Bool = true
    @AppStorage("feed.default") var defaultFeed: FeedSelection = .subscribed
    
    @AppStorage("inbox.showRead") var showReadInInbox: Bool = true
    
    @AppStorage("subscriptions.instanceLocation") var subscriptionInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    @AppStorage("subscriptions.sort") var subscriptionSort: SubscriptionListSort = .alphabetical
    
    @AppStorage("person.showAvatar") var showPersonAvatar: Bool = true
    
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
    @AppStorage("comment.jumpButton") var jumpButton: CommentJumpButtonLocation = .bottomTrailing
    @AppStorage("comment.sort") var commentSort: ApiCommentSortType = .top
    
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
            try await persistenceRepository.saveSystemSettings(self, setting: systemSetting)
            ToastModel.main.add(.success("Saved Settings"))
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Codable Conformance
    
    enum CodingKeys: String, CodingKey {
        case postSize,
             defaultPostSort,
             fallbackPostSort,
             thumbnailLocation,
             showPostCreator,
             quickSwipesEnabled,
             hapticLevel,
             upvoteOnSave,
             internetSpeed,
             keepPlaceOnAccountSwitch,
             accountSort,
             groupAccountSort,
             interfaceStyle,
             colorPalette,
             developerMode,
             blurNsfw,
             showNsfwCommunityWarning,
             openLinksInBrowser,
             openLinksInReaderMode,
             markReadOnScroll,
             showReadInFeed,
             defaultFeed,
             showReadInInbox,
             subscriptionInstanceLocation,
             subscriptionSort,
             showPersonAvatar,
             showCommunityAvatar,
             jumpButton,
             commentSort
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.postSize = try values.decode(PostSize.self, forKey: .postSize)
        self.defaultPostSort = try values.decode(ApiSortType.self, forKey: .defaultPostSort)
        self.fallbackPostSort = try values.decode(ApiSortType.self, forKey: .fallbackPostSort)
        self.thumbnailLocation = try values.decode(ThumbnailLocation.self, forKey: .thumbnailLocation)
        self.showPostCreator = try values.decode(Bool.self, forKey: .showPostCreator)
        self.quickSwipesEnabled = try values.decode(Bool.self, forKey: .quickSwipesEnabled)
        self.hapticLevel = try values.decode(HapticPriority.self, forKey: .hapticLevel)
        self.upvoteOnSave = try values.decode(Bool.self, forKey: .upvoteOnSave)
        self.internetSpeed = try values.decode(InternetSpeed.self, forKey: .internetSpeed)
        self.keepPlaceOnAccountSwitch = try values.decode(Bool.self, forKey: .keepPlaceOnAccountSwitch)
        self.accountSort = try values.decode(AccountSortMode.self, forKey: .accountSort)
        self.groupAccountSort = try values.decode(Bool.self, forKey: .groupAccountSort)
        self.interfaceStyle = try values.decode(UIUserInterfaceStyle.self, forKey: .interfaceStyle)
        self.colorPalette = try values.decode(PaletteOption.self, forKey: .colorPalette)
        self.developerMode = try values.decode(Bool.self, forKey: .developerMode)
        self.blurNsfw = try values.decode(NsfwBlurBehavior.self, forKey: .blurNsfw)
        self.showNsfwCommunityWarning = try values.decode(Bool.self, forKey: .showNsfwCommunityWarning)
        self.openLinksInBrowser = try values.decode(Bool.self, forKey: .openLinksInBrowser)
        self.openLinksInReaderMode = try values.decode(Bool.self, forKey: .openLinksInReaderMode)
        self.markReadOnScroll = try values.decode(Bool.self, forKey: .markReadOnScroll)
        self.showReadInFeed = try values.decode(Bool.self, forKey: .showReadInFeed)
        self.defaultFeed = try values.decode(FeedSelection.self, forKey: .defaultFeed)
        self.showReadInInbox = try values.decode(Bool.self, forKey: .showReadInInbox)
        self.subscriptionInstanceLocation = try values.decode(InstanceLocation.self, forKey: .subscriptionInstanceLocation)
        self.subscriptionSort = try values.decode(SubscriptionListSort.self, forKey: .subscriptionSort)
        self.showPersonAvatar = try values.decode(Bool.self, forKey: .showPersonAvatar)
        self.showCommunityAvatar = try values.decode(Bool.self, forKey: .showCommunityAvatar)
        self.jumpButton = try values.decode(CommentJumpButtonLocation.self, forKey: .jumpButton)
        self.commentSort = try values.decode(ApiCommentSortType.self, forKey: .commentSort)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(postSize, forKey: .postSize)
        try container.encode(defaultPostSort, forKey: .defaultPostSort)
        try container.encode(fallbackPostSort, forKey: .fallbackPostSort)
        try container.encode(thumbnailLocation, forKey: .thumbnailLocation)
        try container.encode(showPostCreator, forKey: .showPostCreator)
        try container.encode(quickSwipesEnabled, forKey: .quickSwipesEnabled)
        try container.encode(hapticLevel, forKey: .hapticLevel)
        try container.encode(upvoteOnSave, forKey: .upvoteOnSave)
        try container.encode(internetSpeed, forKey: .internetSpeed)
        try container.encode(keepPlaceOnAccountSwitch, forKey: .keepPlaceOnAccountSwitch)
        try container.encode(accountSort, forKey: .accountSort)
        try container.encode(groupAccountSort, forKey: .groupAccountSort)
        try container.encode(interfaceStyle, forKey: .interfaceStyle)
        try container.encode(colorPalette, forKey: .colorPalette)
        try container.encode(developerMode, forKey: .developerMode)
        try container.encode(blurNsfw, forKey: .blurNsfw)
        try container.encode(showNsfwCommunityWarning, forKey: .showNsfwCommunityWarning)
        try container.encode(openLinksInBrowser, forKey: .openLinksInBrowser)
        try container.encode(openLinksInReaderMode, forKey: .openLinksInReaderMode)
        try container.encode(markReadOnScroll, forKey: .markReadOnScroll)
        try container.encode(showReadInFeed, forKey: .showReadInFeed)
        try container.encode(defaultFeed, forKey: .defaultFeed)
        try container.encode(showReadInInbox, forKey: .showReadInInbox)
        try container.encode(subscriptionInstanceLocation, forKey: .subscriptionInstanceLocation)
        try container.encode(subscriptionSort, forKey: .subscriptionSort)
        try container.encode(showPersonAvatar, forKey: .showPersonAvatar)
        try container.encode(showCommunityAvatar, forKey: .showCommunityAvatar)
        try container.encode(jumpButton, forKey: .jumpButton)
        try container.encode(commentSort, forKey: .commentSort)
    }
    
    /// Re-initializes all values from the given Settings object. This ensures that AppStorage values get updated canonically.
    @MainActor
    func reinit(from settings: Settings) {
        postSize = settings.postSize
        defaultPostSort = settings.defaultPostSort
        fallbackPostSort = settings.fallbackPostSort
        thumbnailLocation = settings.thumbnailLocation
        showPostCreator = settings.showPostCreator
        quickSwipesEnabled = settings.quickSwipesEnabled
        hapticLevel = settings.hapticLevel
        upvoteOnSave = settings.upvoteOnSave
        internetSpeed = settings.internetSpeed
        keepPlaceOnAccountSwitch = settings.keepPlaceOnAccountSwitch
        accountSort = settings.accountSort
        groupAccountSort = settings.groupAccountSort
        interfaceStyle = settings.interfaceStyle
        colorPalette = settings.colorPalette
        developerMode = settings.developerMode
        blurNsfw = settings.blurNsfw
        showNsfwCommunityWarning = settings.showNsfwCommunityWarning
        openLinksInBrowser = settings.openLinksInBrowser
        openLinksInReaderMode = settings.openLinksInReaderMode
        markReadOnScroll = settings.markReadOnScroll
        showReadInFeed = settings.showReadInFeed
        defaultFeed = settings.defaultFeed
        showReadInInbox = settings.showReadInInbox
        subscriptionInstanceLocation = settings.subscriptionInstanceLocation
        subscriptionSort = settings.subscriptionSort
        showPersonAvatar = settings.showPersonAvatar
        showCommunityAvatar = settings.showCommunityAvatar
        jumpButton = settings.jumpButton
        commentSort = settings.commentSort
    }
}
