//
//  Instance2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

public protocol Instance2Providing: Instance1Providing {
    var instance2: Instance2 { get }
    
    var setup: Bool { get }
    var voteFederationMode: VoteFederationMode { get }
    var nsfwContentEnabled: Bool { get }
    var communityCreationRestrictedToAdmins: Bool { get }
    var emailVerificationRequired: Bool { get }
    var applicationQuestion: String? { get }
    var isPrivate: Bool { get }
    var defaultTheme: String { get }
    var defaultFeed: ListingType { get }
    var legalInformation: String? { get }
    var hideModlogNames: Bool { get }
    var emailApplicationsToAdmins: Bool { get }
    var emailReportsToAdmins: Bool { get }
    var slurFilterRegex: String? { get }
    var actorNameMaxLength: Int { get }
    var federationEnabled: Bool { get }
    var captchaEnabled: Bool { get }
    var captchaDifficulty: CaptchaDifficulty? { get }
    var registrationMode: RegistrationMode { get }
    var federationSignedFetch: Bool? { get }
    var defaultPostListingMode: PostFeedViewMode? { get }
    var defaultPostSortType: PostSortType? { get }
    
    var userCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var communityCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

public extension Instance2Providing {
    var instance1: Instance1 { instance2.instance1 }
    
    var setup: Bool { instance2.setup }
    var voteFederationMode: VoteFederationMode { instance2.voteFederationMode }
    var nsfwContentEnabled: Bool { instance2.nsfwContentEnabled }
    var communityCreationRestrictedToAdmins: Bool { instance2.communityCreationRestrictedToAdmins }
    var emailVerificationRequired: Bool { instance2.emailVerificationRequired }
    var applicationQuestion: String? { instance2.applicationQuestion }
    var isPrivate: Bool { instance2.isPrivate }
    var defaultTheme: String { instance2.defaultTheme }
    var defaultFeed: ListingType { instance2.defaultFeed }
    var legalInformation: String? { instance2.legalInformation }
    var hideModlogNames: Bool { instance2.hideModlogNames }
    var emailApplicationsToAdmins: Bool { instance2.emailApplicationsToAdmins }
    var emailReportsToAdmins: Bool { instance2.emailReportsToAdmins }
    var slurFilterRegex: String? { instance2.slurFilterRegex }
    var actorNameMaxLength: Int { instance2.actorNameMaxLength }
    var federationEnabled: Bool { instance2.federationEnabled }
    var captchaEnabled: Bool { instance2.captchaEnabled }
    var captchaDifficulty: CaptchaDifficulty? { instance2.captchaDifficulty }
    var registrationMode: RegistrationMode { instance2.registrationMode }
    var federationSignedFetch: Bool? { instance2.federationSignedFetch }
    var defaultPostListingMode: PostFeedViewMode? { instance2.defaultPostListingMode }
    var defaultPostSortType: PostSortType? { instance2.defaultPostSortType }
    var userCount: Int { instance2.userCount }
    var postCount: Int { instance2.postCount }
    var commentCount: Int { instance2.commentCount }
    var communityCount: Int { instance2.communityCount }
    var activeUserCount: ActiveUserCount { instance2.activeUserCount }

    var setup_: Bool? { instance2.setup }
    var voteFederationMode_: VoteFederationMode? { instance2.voteFederationMode }
    var nsfwContentEnabled_: Bool? { instance2.nsfwContentEnabled }
    var communityCreationRestrictedToAdmins_: Bool? { instance2.communityCreationRestrictedToAdmins }
    var emailVerificationRequired_: Bool? { instance2.emailVerificationRequired }
    var applicationQuestion_: String? { instance2.applicationQuestion }
    var isPrivate_: Bool? { instance2.isPrivate }
    var defaultTheme_: String? { instance2.defaultTheme }
    var defaultFeed_: ListingType? { instance2.defaultFeed }
    var legalInformation_: String? { instance2.legalInformation }
    var hideModlogNames_: Bool? { instance2.hideModlogNames }
    var emailApplicationsToAdmins_: Bool? { instance2.emailApplicationsToAdmins }
    var emailReportsToAdmins_: Bool? { instance2.emailReportsToAdmins }
    var slurFilterRegex_: String? { instance2.slurFilterRegex }
    var actorNameMaxLength_: Int? { instance2.actorNameMaxLength }
    var federationEnabled_: Bool? { instance2.federationEnabled }
    var captchaEnabled_: Bool? { instance2.captchaEnabled }
    var captchaDifficulty_: CaptchaDifficulty? { instance2.captchaDifficulty }
    var registrationMode_: RegistrationMode? { instance2.registrationMode }
    var federationSignedFetch_: Bool? { instance2.federationSignedFetch }
    var defaultPostListingMode_: PostFeedViewMode? { instance2.defaultPostListingMode }
    var defaultPostSortType_: PostSortType? { instance2.defaultPostSortType }
    var userCount_: Int? { instance2.userCount }
    var postCount_: Int? { instance2.postCount }
    var commentCount_: Int? { instance2.commentCount }
    var communityCount_: Int? { instance2.communityCount }
    var activeUserCount_: ActiveUserCount? { instance2.activeUserCount }
}
