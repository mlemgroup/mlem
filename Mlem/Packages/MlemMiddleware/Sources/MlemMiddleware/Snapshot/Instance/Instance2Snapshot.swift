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
}
