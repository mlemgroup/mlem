//
//  InstanceStubProviding.swift
//
//
//  Created by Sjmarf on 28/05/2024.
//

import Foundation

public protocol InstanceStubProviding: ActorIdentifiable, ContentModel {
    var local: Bool { get }
    
    // From Instance1Providing. These are defined as nil in the extension below
    var id_: Int? { get }
    var instanceId_: Int? { get }
    var displayName_: String? { get }
    var description_: String? { get }
    var shortDescription_: String? { get }
    var avatar_: URL? { get }
    var banner_: URL? { get }
    var created_: Date? { get }
    var updated_: Date? { get }
    var publicKey_: String? { get }
    var lastRefresh_: Date? { get }
    var contentWarning_: String? { get }
    var blocked_: Bool? { get }
    
    // From Instance2Providing. These are defined as nil in the extension below
    var setup_: Bool? { get }
    var downvotesEnabled_: Bool? { get }
    var nsfwContentEnabled_: Bool? { get }
    var communityCreationRestrictedToAdmins_: Bool? { get }
    var emailVerificationRequired_: Bool? { get }
    var applicationQuestion_: String? { get }
    var isPrivate_: Bool? { get }
    var defaultTheme_: String? { get }
    var defaultFeed_: ApiListingType? { get }
    var legalInformation_: String? { get }
    var hideModlogNames_: Bool? { get }
    var emailApplicationsToAdmins_: Bool? { get }
    var emailReportsToAdmins_: Bool? { get }
    var slurFilterRegex_: String? { get }
    var actorNameMaxLength_: Int? { get }
    var federationEnabled_: Bool? { get }
    var captchaEnabled_: Bool? { get }
    var captchaDifficulty_: CaptchaDifficulty? { get }
    var registrationMode_: ApiRegistrationMode? { get }
    var federationSignedFetch_: Bool? { get }
    var defaultPostListingMode_: ApiPostListingMode? { get }
    var defaultSortType_: ApiSortType? { get }
    var userCount_: Int? { get }
    var postCount_: Int? { get }
    var commentCount_: Int? { get }
    var communityCount_: Int? { get }
    var activeUserCount_: ActiveUserCount? { get }
    
    // From Instance3Providing. These are defined as get in the extension below
    var version_: SiteVersion? { get }
    var allLanguages_: [Locale.Language]? { get }
    var allowedLanguageIds_: Set<Int>? { get }
    var taglines_: [ApiTagline]? { get }
    var blockedUrls_: [ApiLocalSiteUrlBlocklist]? { get }
    var administrators_: [Person2]? { get }
}

public extension InstanceStubProviding {
    var id_: Int? { nil }
    var instanceId_: Int? { nil }
    var displayName_: String? { nil }
    var description_: String? { nil }
    var shortDescription_: String? { nil }
    var avatar_: URL? { nil }
    var banner_: URL? { nil }
    var created_: Date? { nil }
    var updated_: Date? { nil }
    var publicKey_: String? { nil }
    var lastRefresh_: Date? { nil }
    var local_: Bool? { nil }
    var contentWarning_: String? { nil }
    
    var setup_: Bool? { nil }
    var downvotesEnabled_: Bool? { nil }
    var nsfwContentEnabled_: Bool? { nil }
    var communityCreationRestrictedToAdmins_: Bool? { nil }
    var emailVerificationRequired_: Bool? { nil }
    var applicationQuestion_: String? { nil }
    var isPrivate_: Bool? { nil }
    var defaultTheme_: String? { nil }
    var defaultFeed_: ApiListingType? { nil }
    var legalInformation_: String? { nil }
    var hideModlogNames_: Bool? { nil }
    var emailApplicationsToAdmins_: Bool? { nil }
    var emailReportsToAdmins_: Bool? { nil }
    var slurFilterRegex_: String? { nil }
    var actorNameMaxLength_: Int? { nil }
    var federationEnabled_: Bool? { nil }
    var captchaEnabled_: Bool? { nil }
    var captchaDifficulty_: CaptchaDifficulty? { nil }
    var registrationMode_: ApiRegistrationMode? { nil }
    var federationSignedFetch_: Bool? { nil }
    var defaultPostListingMode_: ApiPostListingMode? { nil }
    var defaultSortType_: ApiSortType? { nil }
    var userCount_: Int? { nil }
    var postCount_: Int? { nil }
    var commentCount_: Int? { nil }
    var communityCount_: Int? { nil }
    var activeUserCount_: ActiveUserCount? { nil }
    var blocked_: Bool? { nil }
    
    var version_: SiteVersion? { nil }
    var allLanguages_: [Locale.Language]? { nil }
    var allowedLanguageIds_: Set<Int>? { nil }
    var taglines_: [ApiTagline]? { nil }
    var blockedUrls_: [ApiLocalSiteUrlBlocklist]? { nil }
    var administrators_: [Person2]? { nil }
}

public enum InstanceUpgradeError: Error {
    case noPostReturned
    case noSiteReturned
}

public extension InstanceStubProviding {
    /// Upgrade to an ``Instance3``, using the instance's local ``ApiClient``. This will not work for locally running instances.
    func upgradeLocal() async throws -> Instance3 {
        let externalApi: ApiClient = apiIsLocal ? api : .getApiClient(url: actorId.url, username: nil)
        return try await externalApi.getMyInstance()
    }
}
