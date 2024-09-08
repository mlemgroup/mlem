//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import UIKit

struct CodableSettings: Codable {
    var postSize: PostSize
    var defaultPostSort: PostSortType
    var fallbackPostSort: PostSortType
    var thumbnailLocation: String
    var showPostCreator: Bool
    
    var quickSwipesEnabled: Bool
    
    var hapticLevel: HapticPriority
    var upvoteOnSave: Bool
    var internetSpeed: InternetSpeed
    
    var keepPlaceOnAccountSwitch: Bool
    var accountSort: AccountSortMode
    var groupAccountSort: Bool
    
    var interfaceStyle: UIUserInterfaceStyle
    
    var developerMode: Bool
    
    var blurNsfw: String
    
    var openLinksInBrowser: Bool
    var openLinksInReaderMode: Bool
    
    var markReadOnScroll: Bool
    var showReadInFeed: Bool
    var defaultFeed: String
    
    var showReadInInbox: Bool
    
    var showPersonAvatar: Bool
    
    var showCommunityAvatar: Bool
    
    var compactComments: Bool
    var jumpButton: String
    // identical cases minus controversial, should not cause forward compatibility deserialization issues
    var commentSort: CommentSortType
    
    init() {
        @AppStorage("postSize") var postSize: PostSize = .large
        self.postSize = postSize
        
        @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
        self.defaultPostSort = settings.defaultPostSort
        
        @AppStorage("fallbackDefaultPostSorting") var fallbackPostSort: PostSortType = .hot
        self.fallbackPostSort = settings.fallbackPostSort
        
        @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails = true
        @AppStorage("thumbnailsOnRight") var thumbnailsOnRight = false
        if shouldShowPostThumbnails {
            self.thumbnailLocation = thumbnailsOnRight ? "right" : "left"
        } else {
            self.thumbnailLocation = "none"
        }
        
        @AppStorage("shouldShowPostCreator") var shouldShowPostCreator = true
        self.showPostCreator = shouldShowPostCreator
        
        self.quickSwipesEnabled = true
        
        @AppStorage("hapticLevel") var hapticLevel: HapticPriority = .low
        self.hapticLevel = settings.hapticLevel
        
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        self.upvoteOnSave = upvoteOnSave
        
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        self.internetSpeed = internetSpeed

        self.keepPlaceOnAccountSwitch = false
        
        @AppStorage("accountSort") var accountSort: AccountSortMode = .custom
        self.accountSort = accountSort
        
        @AppStorage("groupAccountSort") var groupAccountSort = false
        self.groupAccountSort = groupAccountSort
        
        @AppStorage("lightOrDarkMode") var interfaceStyle: UIUserInterfaceStyle = .unspecified
        self.interfaceStyle = interfaceStyle
        
        @AppStorage("developerMode") var developerMode = false
        self.developerMode = developerMode
        
        @AppStorage("shouldBlurNsfw") var blurNsfw = true
        self.blurNsfw = blurNsfw ? "always" : "never"
        
        @AppStorage("openLinksInBrowser") var openLinksInBrowser = false
        self.openLinksInBrowser = openLinksInBrowser
        
        @AppStorage("openLinksInReaderMode") var openLinksInReaderMode = false
        self.openLinksInReaderMode = openLinksInReaderMode
        
        @AppStorage("markReadOnScroll") var markReadOnScroll = false
        self.markReadOnScroll = markReadOnScroll
        
        @AppStorage("showReadPosts") var showReadInFeed = true
        self.showReadInFeed = showReadInFeed
        
        @AppStorage("defaultFeed") var defaultFeed: DefaultFeedType = .subscribed
        self.defaultFeed = defaultFeed.rawValue // identical cases
        
        @AppStorage("shouldFilterRead") var shouldFilterRead = false
        self.showReadInInbox = !shouldFilterRead
        
        @AppStorage("shouldShowUserAvatars") var showPersonAvatar = true
        self.showPersonAvatar = showPersonAvatar
        
        @AppStorage("shouldShowCommunityIcons") var showCommunityAvatar = true
        self.showCommunityAvatar = showCommunityAvatar
        
        @AppStorage("compactComments") var compactComments = false
        self.compactComments = settings.compactComments
        
        @AppStorage("showCommentJumpButton") var showCommentJumpButton = true
        @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing
        if showCommentJumpButton {
            self.jumpButton = commentJumpButtonSide.rawValue
        } else {
            self.jumpButton = "none"
        }
        
        @AppStorage("defaultCommentSorting") var commentSort: CommentSortType = .top
        self.commentSort = commentSort
    }
}
