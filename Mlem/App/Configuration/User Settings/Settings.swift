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
    public static let main: Settings = .init()

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
    
    @AppStorage("links.openInBrowser") var openLinksInBrowser = false
    @AppStorage("links.readerMode") var openLinksInReaderMode = false
    
    @AppStorage("feed.showRead") var showReadInFeed: Bool = true
    
    @AppStorage("inbox.showRead") var showReadInInbox: Bool = true
    
    @AppStorage("subscriptions.instanceLocation") var subscriptionInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    @AppStorage("subscriptions.sort") var subscriptionSort: SubscriptionListSort = .alphabetical
    
    @AppStorage("person.showAvatar") var showPersonAvatar: Bool = true
    
    @AppStorage("community.showAvatar") var showCommunityAvatar: Bool = true
    
    @AppStorage("comment.jumpButton") var jumpButton: CommentJumpButtonLocation = .bottomTrailing
    @AppStorage("comment.sort") var commentSort: ApiCommentSortType = .top
}
