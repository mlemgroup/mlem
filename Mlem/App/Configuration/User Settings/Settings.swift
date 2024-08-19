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

// Yeah, this is a bit tricky... `ObservableObject` is required for certain updates to work,
// but it isn't designed for use as a global singleton like this, and doesn't properly
// supply updates for non-`AppStorage` properties. `@Observable` handles stored properties,
// correctly but not the `@AppStorage` ones. Using both works o_o
@Observable
class Settings: ObservableObject {
    @ObservationIgnored @Dependency(\.persistenceRepository) private var persistenceRepository
    
    public static let main: Settings = .init()
    
    @ObservationIgnored @AppStorage("post.size")
    var postSize: PostSize = .compact
    @ObservationIgnored @AppStorage("post.defaultSort")
    var defaultPostSort: ApiSortType = .hot
    @ObservationIgnored @AppStorage("post.fallbackSort")
    var fallbackPostSort: ApiSortType = .hot
    @ObservationIgnored @AppStorage("post.thumbnailLocation")
    var thumbnailLocation: ThumbnailLocation = .left
    @ObservationIgnored @AppStorage("post.showCreator")
    var showPostCreator: Bool = false
    
    @ObservationIgnored @AppStorage("quickSwipes.enabled")
    var quickSwipesEnabled: Bool = true
    
    @ObservationIgnored @AppStorage("behavior.hapticLevel")
    var hapticLevel: HapticPriority = .low
    @ObservationIgnored @AppStorage("behavior.upvoteOnSave")
    var upvoteOnSave: Bool = false
    @ObservationIgnored @AppStorage("behavior.internetSpeed")
    var internetSpeed: InternetSpeed = .fast
    
    @ObservationIgnored @AppStorage("accounts.keepPlace")
    var keepPlaceOnAccountSwitch: Bool = false
    @ObservationIgnored @AppStorage("accounts.sort")
    var accountSort: AccountSortMode = .name
    @ObservationIgnored @AppStorage("accounts.groupSort")
    var groupAccountSort: Bool = false
    
    @ObservationIgnored @AppStorage("colorPalette")
    var colorPalette: PaletteOption = .standard
    
    @ObservationIgnored @AppStorage("dev.developerMode")
    var developerMode: Bool = false
    
    @ObservationIgnored @AppStorage("safety.blurNsfw")
    var blurNsfw: Bool = true
    
    @ObservationIgnored @AppStorage("links.openInBrowser")
    var openLinksInBrowser = false
    @ObservationIgnored @AppStorage("links.readerMode")
    var openLinksInReaderMode = false
    
    @ObservationIgnored @AppStorage("feed.showRead")
    var showReadInFeed: Bool = true
    
    @ObservationIgnored @AppStorage("inbox.showRead")
    var showReadInInbox: Bool = true
    
    @ObservationIgnored @AppStorage("subscriptions.instanceLocation")
    var subscriptionInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    @ObservationIgnored @AppStorage("subscriptions.sort")
    var subscriptionSort: SubscriptionListSort = .alphabetical
    
    @ObservationIgnored @AppStorage("person.showAvatar")
    var showPersonAvatar: Bool = true
    
    @ObservationIgnored @AppStorage("community.showAvatar")
    var showCommunityAvatar: Bool = true
    
    var postInteractionBar: PostBarConfiguration {
        get { interactionBarConfigurations.post }
        set { interactionBarConfigurations.post = newValue }
    }
    
    var commentInteractionBar: CommentBarConfiguration {
        get { interactionBarConfigurations.comment }
        set { interactionBarConfigurations.comment = newValue }
    }
    
    var replyInteractionBar: ReplyBarConfiguration {
        get { interactionBarConfigurations.reply }
        set { interactionBarConfigurations.reply = newValue }
    }
    
    var interactionBarConfigurations: InteractionBarConfigurations {
        didSet { Task.detached {
            try await self.persistenceRepository.saveInteractionBarConfigurations(self.interactionBarConfigurations)
        } }
    }
    
    init() {
        self.interactionBarConfigurations = PersistenceRepository.liveValue.loadInteractionBarConfigurations()
    }
}
