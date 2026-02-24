//
//  Instance2.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation
import Observation

@Observable
public final class Instance2: Instance2Providing {
    public static let tierNumber: Int = 2
    public var api: ApiClient
    public var instance2: Instance2 { self }
    
    public let instance1: Instance1
    
    public var setup: Bool

    public var voteFederationMode: VoteFederationMode
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

    public var blockedValue: Bool { instance1.blockedValue }
    
    init(
        api: ApiClient,
        instance1: Instance1,
        setup: Bool,
        voteFederationMode: VoteFederationMode,
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
        self.api = api
        self.instance1 = instance1
        self.setup = setup
        self.voteFederationMode = voteFederationMode
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
