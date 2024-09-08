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
    
    /// Re-initializes all values from the given Settings object. This ensures that AppStorage values get updated canonically.
    @MainActor
    func reinit(from settings: CodableSettings) {
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
