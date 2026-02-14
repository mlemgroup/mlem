//
//  PersonProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

import Foundation

public struct PersonProperties: UnifiedPropertiesProviding {
    // From Person1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let name: String
    let created: Date
    let instanceId: Int
    var displayName: String
    var avatar: URL?
    var banner: URL?
    var note: String?
    var updated: Date?
    var description: String?
    var matrixUserId: String?
    var isBot: Bool
    var instanceBan: InstanceBanType
    var deleted: Bool
    
    // From Person2Snapshot
    var isAdmin: Bool?
    var postCount: Int?
    var commentCount: Int?
    
    // From Person3Snapshot
    var instance: (any Instance)?
    var moderatedCommunities: [any DeprecatedCommunity]?
    
    // From Person4Snapshot
    var email: String??
    var showNsfw: Bool?
    var theme: String?
    var defaultListingType: ListingType?
    var interfaceLanguage: String?
    var showAvatars: Bool?
    var sendNotificationsToEmail: Bool?
    var showScores: Bool?
    var showBotAccounts: Bool?
    var showReadPosts: Bool?
    var discussionLanguageIds: Set<Int>?
    var emailVerified: Bool?
    var acceptedApplication: Bool?
    var openLinksInNewTab: Bool??
    var blurNsfw: Bool??
    var autoExpandImages: Bool??
    var infiniteScrollEnabled: Bool??
    var postListingMode: PostFeedViewMode??
    var totp2faEnabled: Bool??
    var enableKeyboardNavigation: Bool??
    var enableAnimatedImages: Bool??
    var collapseBotComments: Bool??
    
    @MainActor
    public init(api: ApiClient, snapshot: AnyPersonSnapshot) {
        let snapshot1: Person1Snapshot
        let snapshot2: Person2Snapshot?
        let snapshot3: Person3Snapshot?
        let snapshot4: Person4Snapshot?
        switch snapshot {
        case let .person1(person1Snapshot):
            snapshot1 = person1Snapshot
            snapshot2 = nil
            snapshot3 = nil
            snapshot4 = nil
        case let .person2(person2Snapshot):
            snapshot1 = person2Snapshot.person
            snapshot2 = person2Snapshot
            snapshot3 = nil
            snapshot4 = nil
        case let .person3(person3Snapshot):
            snapshot1 = person3Snapshot.person.person
            snapshot2 = person3Snapshot.person
            snapshot3 = person3Snapshot
            snapshot4 = nil
        case let .person4(person4Snapshot):
            snapshot1 = person4Snapshot.person.person.person
            snapshot2 = person4Snapshot.person.person
            snapshot3 = person4Snapshot.person
            snapshot4 = person4Snapshot
        }
        
        if let snapshot4 {
            email = snapshot4.email
            showNsfw = snapshot4.showNsfw
            theme = snapshot4.theme
            defaultListingType = snapshot4.defaultListingType
            interfaceLanguage = snapshot4.interfaceLanguage
            showAvatars = snapshot4.showAvatars
            sendNotificationsToEmail = snapshot4.sendNotificationsToEmail
            showScores = snapshot4.showScores
            showBotAccounts = snapshot4.showBotAccounts
            showReadPosts = snapshot4.showReadPosts
            discussionLanguageIds = snapshot4.discussionLanguageIds
            emailVerified = snapshot4.emailVerified
            acceptedApplication = snapshot4.acceptedApplication
            openLinksInNewTab = snapshot4.openLinksInNewTab
            blurNsfw = snapshot4.blurNsfw
            autoExpandImages = snapshot4.autoExpandImages
            infiniteScrollEnabled = snapshot4.infiniteScrollEnabled
            postListingMode = snapshot4.postListingMode
            totp2faEnabled = snapshot4.totp2faEnabled
            enableKeyboardNavigation = snapshot4.enableKeyboardNavigation
            enableAnimatedImages = snapshot4.enableAnimatedImages
            collapseBotComments = snapshot4.collapseBotComments
        }
        
        if let snapshot3 {
            if let site = snapshot3.site {
                instance = api.caches.instance1.getModel(api: api, from: site)
            }
            moderatedCommunities = api.caches.community1.getModels(api: api, from: snapshot3.moderatedCommunities)
        }
        
        if let snapshot2 {
            isAdmin = snapshot2.isAdmin
            postCount = snapshot2.postCount
            commentCount = snapshot2.commentCount
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        name = snapshot1.name
        created = snapshot1.created
        instanceId = snapshot1.instanceId
        displayName = snapshot1.displayName
        avatar = snapshot1.avatar
        banner = snapshot1.banner
        note = snapshot1.note
        updated = snapshot1.updated
        description = snapshot1.description
        matrixUserId = snapshot1.matrixUserId
        isBot = snapshot1.isBot
        instanceBan = snapshot1.instanceBan
        deleted = snapshot1.deleted
    }
    
    public mutating func merge(_ other: PersonProperties) {
        // tier 1 properties: simple assignment
        self.displayName = other.displayName
        self.avatar = other.avatar
        self.banner = other.banner
        self.note = other.note
        self.updated = other.updated
        self.description = other.description
        self.matrixUserId = other.matrixUserId
        self.isBot = other.isBot
        self.instanceBan = other.instanceBan
        self.deleted = other.deleted
        
        // tier 2, 3, 4 properties: only assign if incoming non-nil
        isAdmin = other.isAdmin ?? self.isAdmin
        postCount = other.postCount ?? self.postCount
        commentCount = other.commentCount ?? self.commentCount

        instance = other.instance ?? self.instance
        moderatedCommunities = other.moderatedCommunities ?? self.moderatedCommunities
        
        email = other.email ?? self.email
        showNsfw = other.showNsfw ?? self.showNsfw
        theme = other.theme ?? self.theme
        defaultListingType = other.defaultListingType ?? self.defaultListingType
        interfaceLanguage = other.interfaceLanguage ?? self.interfaceLanguage
        showAvatars = other.showAvatars ?? self.showAvatars
        sendNotificationsToEmail = other.sendNotificationsToEmail ?? self.sendNotificationsToEmail
        showScores = other.showScores ?? self.showScores
        showBotAccounts = other.showBotAccounts ?? self.showBotAccounts
        showReadPosts = other.showReadPosts ?? self.showReadPosts
        discussionLanguageIds = other.discussionLanguageIds ?? self.discussionLanguageIds
        emailVerified = other.emailVerified ?? self.emailVerified
        acceptedApplication = other.acceptedApplication ?? self.acceptedApplication
        openLinksInNewTab = other.openLinksInNewTab ?? self.openLinksInNewTab
        blurNsfw = other.blurNsfw ?? self.blurNsfw
        autoExpandImages = other.autoExpandImages ?? self.autoExpandImages
        infiniteScrollEnabled = other.infiniteScrollEnabled ?? self.infiniteScrollEnabled
        postListingMode = other.postListingMode ?? self.postListingMode
        totp2faEnabled = other.totp2faEnabled ?? self.totp2faEnabled
        enableKeyboardNavigation = other.enableKeyboardNavigation ?? self.enableKeyboardNavigation
        enableAnimatedImages = other.enableAnimatedImages ?? self.enableAnimatedImages
        collapseBotComments = other.collapseBotComments ?? self.collapseBotComments
    }
}
