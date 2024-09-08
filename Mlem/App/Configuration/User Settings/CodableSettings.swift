//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import MlemMiddleware
import UIKit

/// Mirror of Settings but without any AppStorage complexity and fully optionalized. This is not pretty but prevents
struct CodableSettings: Codable {
    var postSize: PostSize?
    var defaultPostSort: ApiSortType?
    var fallbackPostSort: ApiSortType?
    var thumbnailLocation: ThumbnailLocation?
    var showPostCreator: Bool?
    
    var quickSwipesEnabled: Bool?
    
    var hapticLevel: HapticPriority?
    var upvoteOnSave: Bool?
    var internetSpeed: InternetSpeed?
    
    var keepPlaceOnAccountSwitch: Bool?
    var accountSort: AccountSortMode?
    var groupAccountSort: Bool?
    
    var interfaceStyle: UIUserInterfaceStyle?
    var colorPalette: PaletteOption?
    
    var developerMode: Bool?
    
    var blurNsfw: NsfwBlurBehavior?
    var showNsfwCommunityWarning: Bool?
    
    var openLinksInBrowser: Bool?
    var openLinksInReaderMode: Bool?
    
    var markReadOnScroll: Bool?
    var showReadInFeed: Bool?
    var defaultFeed: FeedSelection?
    
    var showReadInInbox: Bool?
    
    var subscriptionInstanceLocation: InstanceLocation?
    
    var subscriptionSort: SubscriptionListSort?
    
    var showPersonAvatar: Bool?
    
    var showCommunityAvatar: Bool?
    
    var compactComments: Bool?
    var jumpButton: CommentJumpButtonLocation?
    var commentSort: ApiCommentSortType?
    
    override func decode
    
    init(from settings: Settings) {
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
        compactComments = settings.compactComments
        jumpButton = settings.jumpButton
        commentSort = settings.commentSort
    }
}
