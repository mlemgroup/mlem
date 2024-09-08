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
    
    @AppStorage("comment.compact") var compactComments: Bool = false
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
    
    /// Re-initializes all values from the given CodableSettings object. Any null keys in CodableSettings will be ignored.
    @MainActor
    func reinit(from settings: CodableSettings) {
        postSize = settings.postSize ?? postSize
        defaultPostSort = settings.defaultPostSort ?? defaultPostSort
        fallbackPostSort = settings.fallbackPostSort ?? fallbackPostSort
        thumbnailLocation = settings.thumbnailLocation ?? thumbnailLocation
        showPostCreator = settings.showPostCreator ?? showPostCreator
        quickSwipesEnabled = settings.quickSwipesEnabled ?? quickSwipesEnabled
        hapticLevel = settings.hapticLevel ?? hapticLevel
        upvoteOnSave = settings.upvoteOnSave ?? upvoteOnSave
        internetSpeed = settings.internetSpeed ?? internetSpeed
        keepPlaceOnAccountSwitch = settings.keepPlaceOnAccountSwitch ?? keepPlaceOnAccountSwitch
        accountSort = settings.accountSort ?? accountSort
        groupAccountSort = settings.groupAccountSort ?? groupAccountSort
        interfaceStyle = settings.interfaceStyle ?? interfaceStyle
        colorPalette = settings.colorPalette ?? colorPalette
        developerMode = settings.developerMode ?? developerMode
        blurNsfw = settings.blurNsfw ?? blurNsfw
        showNsfwCommunityWarning = settings.showNsfwCommunityWarning ?? showNsfwCommunityWarning
        openLinksInBrowser = settings.openLinksInBrowser ?? openLinksInBrowser
        openLinksInReaderMode = settings.openLinksInReaderMode ?? openLinksInReaderMode
        markReadOnScroll = settings.markReadOnScroll ?? markReadOnScroll
        showReadInFeed = settings.showReadInFeed ?? showReadInFeed
        defaultFeed = settings.defaultFeed ?? defaultFeed
        showReadInInbox = settings.showReadInInbox ?? showReadInInbox
        subscriptionInstanceLocation = settings.subscriptionInstanceLocation ?? subscriptionInstanceLocation
        subscriptionSort = settings.subscriptionSort ?? subscriptionSort
        showPersonAvatar = settings.showPersonAvatar ?? showPersonAvatar
        showCommunityAvatar = settings.showCommunityAvatar ?? showCommunityAvatar
        compactComments = settings.compactComments ?? compactComments
        jumpButton = settings.jumpButton ?? jumpButton
        commentSort = settings.commentSort ?? commentSort
    }
}
