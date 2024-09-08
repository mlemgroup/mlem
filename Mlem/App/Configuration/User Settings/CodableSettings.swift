//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import MlemMiddleware
import UIKit

struct CodableSettings: Codable {
    var postSize: PostSize
    var defaultPostSort: ApiSortType
    var fallbackPostSort: ApiSortType
    var thumbnailLocation: ThumbnailLocation
    var showPostCreator: Bool
    
    var quickSwipesEnabled: Bool
    
    var hapticLevel: HapticPriority
    var upvoteOnSave: Bool = false
    var internetSpeed: InternetSpeed
    
    var keepPlaceOnAccountSwitch: Bool
    var accountSort: AccountSortMode
    var groupAccountSort: Bool
    
    var interfaceStyle: UIUserInterfaceStyle
    var colorPalette: PaletteOption
    
    var developerMode: Bool
    
    var blurNsfw: NsfwBlurBehavior
    var showNsfwCommunityWarning: Bool
    
    var openLinksInBrowser: Bool
    var openLinksInReaderMode: Bool
    
    var markReadOnScroll: Bool
    var showReadInFeed: Bool
    var defaultFeed: FeedSelection
    
    var showReadInInbox: Bool
    
    var subscriptionInstanceLocation: InstanceLocation
    
    var subscriptionSort: SubscriptionListSort
    
    var showPersonAvatar: Bool
    
    var showCommunityAvatar: Bool
    
    var jumpButton: CommentJumpButtonLocation
    var commentSort: ApiCommentSortType
    
    init(from settings: Settings) {
        self.postSize = settings.postSize
        self.defaultPostSort = settings.defaultPostSort
        self.fallbackPostSort = settings.fallbackPostSort
        self.thumbnailLocation = settings.thumbnailLocation
        self.showPostCreator = settings.showPostCreator
        self.quickSwipesEnabled = settings.quickSwipesEnabled
        self.hapticLevel = settings.hapticLevel
        self.upvoteOnSave = settings.upvoteOnSave
        self.internetSpeed = settings.internetSpeed
        self.keepPlaceOnAccountSwitch = settings.keepPlaceOnAccountSwitch
        self.accountSort = settings.accountSort
        self.groupAccountSort = settings.groupAccountSort
        self.interfaceStyle = settings.interfaceStyle
        self.colorPalette = settings.colorPalette
        self.developerMode = settings.developerMode
        self.blurNsfw = settings.blurNsfw
        self.showNsfwCommunityWarning = settings.showNsfwCommunityWarning
        self.openLinksInBrowser = settings.openLinksInBrowser
        self.openLinksInReaderMode = settings.openLinksInReaderMode
        self.markReadOnScroll = settings.markReadOnScroll
        self.showReadInFeed = settings.showReadInFeed
        self.defaultFeed = settings.defaultFeed
        self.showReadInInbox = settings.showReadInInbox
        self.subscriptionInstanceLocation = settings.subscriptionInstanceLocation
        self.subscriptionSort = settings.subscriptionSort
        self.showPersonAvatar = settings.showPersonAvatar
        self.showCommunityAvatar = settings.showCommunityAvatar
        self.jumpButton = settings.jumpButton
        self.commentSort = settings.commentSort
    }
}
