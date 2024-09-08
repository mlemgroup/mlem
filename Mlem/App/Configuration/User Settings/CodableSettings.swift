//
//  CodableSettings.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-05.
//

import Foundation
import MlemMiddleware
import UIKit

/// Mirror of Settings but without any AppStorage complexity and fully optionalized.
struct CodableSettings: Codable {
    var postSize: PostSize
    var defaultPostSort: ApiSortType
    var fallbackPostSort: ApiSortType
    var thumbnailLocation: ThumbnailLocation
    var showPostCreator: Bool
    
    var quickSwipesEnabled: Bool
    
    var hapticLevel: HapticPriority
    var upvoteOnSave: Bool
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
    
    var compactComments: Bool
    var jumpButton: CommentJumpButtonLocation
    var commentSort: ApiCommentSortType
    
    // swiftlint:disable line_length
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.postSize = try container.decodeIfPresent(PostSize.self, forKey: .postSize) ?? .compact
        self.defaultPostSort = try container.decodeIfPresent(ApiSortType.self, forKey: .defaultPostSort) ?? .hot
        self.fallbackPostSort = try container.decodeIfPresent(ApiSortType.self, forKey: .fallbackPostSort) ?? .hot
        self.thumbnailLocation = try container.decodeIfPresent(ThumbnailLocation.self, forKey: .thumbnailLocation) ?? .left
        self.showPostCreator = try container.decodeIfPresent(Bool.self, forKey: .showPostCreator) ?? false
        self.quickSwipesEnabled = try container.decodeIfPresent(Bool.self, forKey: .quickSwipesEnabled) ?? true
        self.hapticLevel = try container.decodeIfPresent(HapticPriority.self, forKey: .hapticLevel) ?? .low
        self.upvoteOnSave = try container.decodeIfPresent(Bool.self, forKey: .upvoteOnSave) ?? false
        self.internetSpeed = try container.decodeIfPresent(InternetSpeed.self, forKey: .internetSpeed) ?? .fast
        self.keepPlaceOnAccountSwitch = try container.decodeIfPresent(Bool.self, forKey: .keepPlaceOnAccountSwitch) ?? false
        self.accountSort = try container.decodeIfPresent(AccountSortMode.self, forKey: .accountSort) ?? .name
        self.groupAccountSort = try container.decodeIfPresent(Bool.self, forKey: .groupAccountSort) ?? false
        self.interfaceStyle = try container.decodeIfPresent(UIUserInterfaceStyle.self, forKey: .interfaceStyle) ?? .unspecified
        self.colorPalette = try container.decodeIfPresent(PaletteOption.self, forKey: .colorPalette) ?? .standard
        self.developerMode = try container.decodeIfPresent(Bool.self, forKey: .developerMode) ?? false
        self.blurNsfw = try container.decodeIfPresent(NsfwBlurBehavior.self, forKey: .blurNsfw) ?? .always
        self.showNsfwCommunityWarning = try container.decodeIfPresent(Bool.self, forKey: .showNsfwCommunityWarning) ?? true
        self.openLinksInBrowser = try container.decodeIfPresent(Bool.self, forKey: .openLinksInBrowser) ?? false
        self.openLinksInReaderMode = try container.decodeIfPresent(Bool.self, forKey: .openLinksInReaderMode) ?? false
        self.markReadOnScroll = try container.decodeIfPresent(Bool.self, forKey: .markReadOnScroll) ?? false
        self.showReadInFeed = try container.decodeIfPresent(Bool.self, forKey: .showReadInFeed) ?? true
        self.defaultFeed = try container.decodeIfPresent(FeedSelection.self, forKey: .defaultFeed) ?? .subscribed
        self.showReadInInbox = try container.decodeIfPresent(Bool.self, forKey: .showReadInInbox) ?? true
        self.subscriptionInstanceLocation = try container.decodeIfPresent(InstanceLocation.self, forKey: .subscriptionInstanceLocation) ?? (UIDevice.isPad ? .bottom : .trailing)
        self.subscriptionSort = try container.decodeIfPresent(SubscriptionListSort.self, forKey: .subscriptionSort) ?? .alphabetical
        self.showPersonAvatar = try container.decodeIfPresent(Bool.self, forKey: .showPersonAvatar) ?? true
        self.showCommunityAvatar = try container.decodeIfPresent(Bool.self, forKey: .showCommunityAvatar) ?? true
        self.compactComments = try container.decodeIfPresent(Bool.self, forKey: .compactComments) ?? false
        self.jumpButton = try container.decodeIfPresent(CommentJumpButtonLocation.self, forKey: .jumpButton) ?? .bottomTrailing
        self.commentSort = try container.decodeIfPresent(ApiCommentSortType.self, forKey: .commentSort) ?? .top
    }

    // swiftlint:enable line_length
    
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
        self.compactComments = settings.compactComments
        self.jumpButton = settings.jumpButton
        self.commentSort = settings.commentSort
    }
}
