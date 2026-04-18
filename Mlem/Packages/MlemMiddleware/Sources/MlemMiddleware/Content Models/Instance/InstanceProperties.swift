//
//  InstanceProperties.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-03-13.
//

import Foundation

public struct InstanceProperties: UnifiedPropertiesProviding {
    // From Instance1Snapshot, guaranteed to always be present
    let actorId: ActorIdentifier
    let id: Int
    let instanceId: Int
    let created: Date
    let updated: Date?
    let publicKey: String
    var displayName: String
    var description: String?
    var shortDescription: String?
    var avatar: URL?
    var banner: URL?
    var lastRefresh: Date
    var contentWarning: String?
    
    // From Instance2Snapshot
    var setup: Bool?
    var voteFederationMode: VoteFederationMode?
    var nsfwContentEnabled: Bool?
    var communityCreationRestrictedToAdmins: Bool?
    var emailVerificationRequired: Bool?
    var applicationQuestion: String??
    var isPrivate: Bool?
    var defaultTheme: String?
    var defaultFeed: ListingType?
    var legalInformation: String??
    var hideModlogNames: Bool?
    var emailApplicationsToAdmins: Bool?
    var emailReportsToAdmins: Bool?
    var slurFilterRegex: String??
    var actorNameMaxLength: Int?
    var federationEnabled: Bool?
    var captchaEnabled: Bool?
    var captchaDifficulty: CaptchaDifficulty??
    var registrationMode: RegistrationMode?
    var federationSignedFetch: Bool??
    var defaultPostListingMode: PostFeedViewMode??
    var defaultPostSortType: PostSortType??
    var userCount: Int?
    var postCount: Int?
    var commentCount: Int?
    var communityCount: Int?
    var activeUserCount: ActiveUserCount?
    
    // From Instance3Snapshot
    let allLanguages: [Locale.Language]?
    var software: SiteSoftware?
    var allowedLanguageIds: Set<Int>?
    var blockedUrls: [InstanceUrlBlockRecord]??
    var administrators: [Person]?
    
    // Constructs an InstanceProperties from a given snapshot
    @MainActor
    public init(api: ApiClient, snapshot: AnyInstanceSnapshot) {
        let snapshot1: Instance1Snapshot
        let snapshot2: Instance2Snapshot?
        let snapshot3: Instance3Snapshot?
        switch snapshot {
        case let .instance1(instance1Snapshot):
            snapshot1 = instance1Snapshot
            snapshot2 = nil
            snapshot3 = nil
        case let .instance2(instance2Snapshot):
            snapshot1 = instance2Snapshot.instance
            snapshot2 = instance2Snapshot
            snapshot3 = nil
        case let .instance3(instance3Snapshot):
            snapshot1 = instance3Snapshot.instance.instance
            snapshot2 = instance3Snapshot.instance
            snapshot3 = instance3Snapshot
        }
        
        if let snapshot3 {
            allLanguages = snapshot3.allLanguages
            software = snapshot3.software
            allowedLanguageIds = snapshot3.allowedLanguageIds
            blockedUrls = snapshot3.blockedUrls
            administrators = api.caches.person.getModels(api: api, from: snapshot3.administrators.map { .person2($0) })
        } else {
            allLanguages = nil // needs special handling because it's a let
        }
        
        if let snapshot2 {
            setup = snapshot2.setup
            voteFederationMode = snapshot2.voteFederationMode
            nsfwContentEnabled = snapshot2.nsfwContentEnabled
            communityCreationRestrictedToAdmins = snapshot2.communityCreationRestrictedToAdmins
            emailVerificationRequired = snapshot2.emailVerificationRequired
            applicationQuestion = snapshot2.applicationQuestion
            isPrivate = snapshot2.isPrivate
            defaultTheme = snapshot2.defaultTheme
            defaultFeed = snapshot2.defaultFeed
            legalInformation = snapshot2.legalInformation
            hideModlogNames = snapshot2.hideModlogNames
            emailApplicationsToAdmins = snapshot2.emailApplicationsToAdmins
            emailReportsToAdmins = snapshot2.emailReportsToAdmins
            slurFilterRegex = snapshot2.slurFilterRegex
            actorNameMaxLength = snapshot2.actorNameMaxLength
            federationEnabled = snapshot2.federationEnabled
            captchaEnabled = snapshot2.captchaEnabled
            captchaDifficulty = snapshot2.captchaDifficulty
            registrationMode = snapshot2.registrationMode
            federationSignedFetch = snapshot2.federationSignedFetch
            defaultPostListingMode = snapshot2.defaultPostListingMode
            defaultPostSortType = snapshot2.defaultPostSortType
            userCount = snapshot2.userCount
            postCount = snapshot2.postCount
            commentCount = snapshot2.commentCount
            communityCount = snapshot2.communityCount
            activeUserCount = snapshot2.activeUserCount
        }
        
        actorId = snapshot1.actorId
        id = snapshot1.id
        instanceId = snapshot1.instanceId
        created = snapshot1.created
        updated = snapshot1.updated
        publicKey = snapshot1.publicKey
        displayName = snapshot1.displayName
        description = snapshot1.description
        shortDescription = snapshot1.shortDescription
        avatar = snapshot1.avatar
        banner = snapshot1.banner
        lastRefresh = snapshot1.lastRefresh
        contentWarning = snapshot1.contentWarning
    }
    
    public mutating func merge(_ other: InstanceProperties) {
        // tier 1 properties: simple assignment
        self.displayName = other.displayName
        self.description = other.description
        self.shortDescription = other.shortDescription
        self.avatar = other.avatar
        self.banner = other.banner
        self.lastRefresh = other.lastRefresh
        self.contentWarning = other.contentWarning
        
        // tier 2, 3 properties: only assign if incoming non-nil
        self.setup = other.setup ?? self.setup
        self.voteFederationMode = other.voteFederationMode ?? self.voteFederationMode
        self.nsfwContentEnabled = other.nsfwContentEnabled ?? self.nsfwContentEnabled
        self.communityCreationRestrictedToAdmins = other.communityCreationRestrictedToAdmins ?? self.communityCreationRestrictedToAdmins
        self.emailVerificationRequired = other.emailVerificationRequired ?? self.emailVerificationRequired
        self.applicationQuestion = other.applicationQuestion ?? self.applicationQuestion
        self.isPrivate = other.isPrivate ?? self.isPrivate
        self.defaultTheme = other.defaultTheme ?? self.defaultTheme
        self.defaultFeed = other.defaultFeed ?? self.defaultFeed
        self.legalInformation = other.legalInformation ?? self.legalInformation
        self.hideModlogNames = other.hideModlogNames ?? self.hideModlogNames
        self.emailApplicationsToAdmins = other.emailApplicationsToAdmins ?? self.emailApplicationsToAdmins
        self.emailReportsToAdmins = other.emailReportsToAdmins ?? self.emailReportsToAdmins
        self.slurFilterRegex = other.slurFilterRegex ?? self.slurFilterRegex
        self.actorNameMaxLength = other.actorNameMaxLength ?? self.actorNameMaxLength
        self.federationEnabled = other.federationEnabled ?? self.federationEnabled
        self.captchaEnabled = other.captchaEnabled ?? self.captchaEnabled
        self.captchaDifficulty = other.captchaDifficulty ?? self.captchaDifficulty
        self.registrationMode = other.registrationMode ?? self.registrationMode
        self.federationSignedFetch = other.federationSignedFetch ?? self.federationSignedFetch
        self.defaultPostListingMode = other.defaultPostListingMode ?? self.defaultPostListingMode
        self.defaultPostSortType = other.defaultPostSortType ?? self.defaultPostSortType
        self.userCount = other.userCount ?? self.userCount
        self.postCount = other.postCount ?? self.postCount
        self.commentCount = other.commentCount ?? self.commentCount
        self.communityCount = other.communityCount ?? self.communityCount
        self.activeUserCount = other.activeUserCount ?? self.activeUserCount
        
        self.software = other.software ?? self.software
        self.allowedLanguageIds = other.allowedLanguageIds ?? self.allowedLanguageIds
        self.blockedUrls = other.blockedUrls ?? self.blockedUrls
        self.administrators = other.administrators ?? self.administrators
    }
}
