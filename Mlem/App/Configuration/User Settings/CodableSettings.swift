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
}
