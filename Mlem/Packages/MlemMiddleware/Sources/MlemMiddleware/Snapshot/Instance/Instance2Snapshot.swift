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
    
    public init(from site: LemmySiteView) throws(ApiClientError) {
        self.instance = try .init(from: site.site)
        self.setup = site.localSite.siteSetup
        
        // TODO: 1.0 support
        self.downvotesEnabled = site.localSite.enableDownvotes ?? false
        
        if let blockNsfw = site.localSite.disallowNsfwContent {
            self.nsfwContentEnabled = !blockNsfw
        } else if let enableNsfw = site.localSite.enableNsfw {
            self.nsfwContentEnabled = enableNsfw
        } else {
            throw .responseMissingRequiredData("ApiSiteView enableNsfw")
        }
        
        self.communityCreationRestrictedToAdmins = site.localSite.communityCreationAdminOnly
        self.emailVerificationRequired = site.localSite.requireEmailVerification
        self.applicationQuestion = site.localSite.applicationQuestion
        self.isPrivate = site.localSite.privateInstance
        self.defaultTheme = site.localSite.defaultTheme
        self.defaultFeed = try .init(from: site.localSite.defaultPostListingType)
        self.legalInformation = site.localSite.legalInformation
        self.hideModlogNames = site.localSite.hideModlogModNames ?? true // Always hidden in 1.0
        self.emailApplicationsToAdmins = site.localSite.applicationEmailAdmins
        self.emailReportsToAdmins = site.localSite.reportsEmailAdmins
        self.slurFilterRegex = site.localSite.slurFilterRegex
        self.actorNameMaxLength = site.localSite.actorNameMaxLength
        self.federationEnabled = site.localSite.federationEnabled
        self.captchaEnabled = site.localSite.captchaEnabled
        self.captchaDifficulty = .init(rawValue: site.localSite.captchaDifficulty)
        self.registrationMode = .init(from: site.localSite.registrationMode)
        self.federationSignedFetch = site.localSite.federationSignedFetch
        self.defaultPostListingMode = site.localSite.defaultPostListingMode.map { .init(from: $0) }
        self.defaultPostSortType = site.localSite.defaultSortType.map { .init($0) }
        
        if let counts = site.counts {
            self.userCount = counts.users
            self.postCount = counts.posts
            self.commentCount = counts.comments
            self.communityCount = counts.communities
            self.activeUserCount = .init(
                sixMonths: counts.usersActiveHalfYear,
                month: counts.usersActiveMonth,
                week: counts.usersActiveWeek,
                day: counts.usersActiveDay
            )
        } else {
            guard let users = site.localSite.users else { throw .responseMissingRequiredData("LemmySiteView users") }
            self.userCount = users
            guard let posts = site.localSite.posts else { throw .responseMissingRequiredData("LemmySiteView posts") }
            self.postCount = posts
            guard let comments = site.localSite.comments else { throw .responseMissingRequiredData("LemmySiteView comments") }
            self.commentCount = comments
            guard let communities = site.localSite.communities else { throw .responseMissingRequiredData("LemmySiteView communities") }
            self.communityCount = communities
            guard let sixMonths = site.localSite.usersActiveHalfYear else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let month = site.localSite.usersActiveMonth else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let week = site.localSite.usersActiveWeek else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let day = site.localSite.usersActiveHalfYear else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            self.activeUserCount = .init(
                sixMonths: sixMonths,
                month: month,
                week: week,
                day: day
            )
        }
    }
}
