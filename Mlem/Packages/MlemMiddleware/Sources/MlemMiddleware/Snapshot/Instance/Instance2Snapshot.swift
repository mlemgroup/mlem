//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-11.
//

import Foundation

public struct Instance2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Instance2.
    public let instance: Instance1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post2!
    public var setup: Bool
    public var downvotesEnabled: Bool
    public var nsfwContentEnabled: Bool
    public var communityCreationRestrictedToAdmins: Bool
    public var emailVerificationRequired: Bool
    public var applicationQuestion: String?
    public var isPrivate: Bool
    public var defaultTheme: String
    public var defaultFeed: ListingType
    public var legalInformation: String?
    public var hideModlogNames: Bool
    public var emailApplicationsToAdmins: Bool
    public var emailReportsToAdmins: Bool
    public var slurFilterRegex: String?
    public var actorNameMaxLength: Int
    public var federationEnabled: Bool
    public var captchaEnabled: Bool
    public var captchaDifficulty: CaptchaDifficulty?
    public var registrationMode: RegistrationMode
    public var federationSignedFetch: Bool?
    public var defaultPostListingMode: PostFeedViewMode?
    public var defaultPostSortType: PostSortType?
    public var userCount: Int
    public var postCount: Int
    public var commentCount: Int
    public var communityCount: Int
    public var activeUserCount: ActiveUserCount
    
    public var cacheId: Int { instance.cacheId }
    
    public init(
        instance: Instance1Snapshot,
        setup: Bool,
        downvotesEnabled: Bool,
        nsfwContentEnabled: Bool,
        communityCreationRestrictedToAdmins: Bool,
        emailVerificationRequired: Bool,
        applicationQuestion: String? = nil,
        isPrivate: Bool,
        defaultTheme: String,
        defaultFeed: ListingType,
        legalInformation: String? = nil,
        hideModlogNames: Bool,
        emailApplicationsToAdmins: Bool,
        emailReportsToAdmins: Bool,
        slurFilterRegex: String? = nil,
        actorNameMaxLength: Int,
        federationEnabled: Bool,
        captchaEnabled: Bool,
        captchaDifficulty: CaptchaDifficulty? = nil,
        registrationMode: RegistrationMode,
        federationSignedFetch: Bool? = nil,
        defaultPostListingMode: PostFeedViewMode? = nil,
        defaultPostSortType: PostSortType? = nil,
        userCount: Int,
        postCount: Int,
        commentCount: Int,
        communityCount: Int,
        activeUserCount: ActiveUserCount
    ) {
        self.instance = instance
        self.setup = setup
        self.downvotesEnabled = downvotesEnabled
        self.nsfwContentEnabled = nsfwContentEnabled
        self.communityCreationRestrictedToAdmins = communityCreationRestrictedToAdmins
        self.emailVerificationRequired = emailVerificationRequired
        self.applicationQuestion = applicationQuestion
        self.isPrivate = isPrivate
        self.defaultTheme = defaultTheme
        self.defaultFeed = defaultFeed
        self.legalInformation = legalInformation
        self.hideModlogNames = hideModlogNames
        self.emailApplicationsToAdmins = emailApplicationsToAdmins
        self.emailReportsToAdmins = emailReportsToAdmins
        self.slurFilterRegex = slurFilterRegex
        self.actorNameMaxLength = actorNameMaxLength
        self.federationEnabled = federationEnabled
        self.captchaEnabled = captchaEnabled
        self.captchaDifficulty = captchaDifficulty
        self.registrationMode = registrationMode
        self.federationSignedFetch = federationSignedFetch
        self.defaultPostListingMode = defaultPostListingMode
        self.defaultPostSortType = defaultPostSortType
        self.userCount = userCount
        self.postCount = postCount
        self.commentCount = commentCount
        self.communityCount = communityCount
        self.activeUserCount = activeUserCount
    }
}
