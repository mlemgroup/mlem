//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension Instance2Snapshot {
    init(pieFed: PieFedSite, lemmy: PieFedLemmyCompatibleSiteView) throws(ApiClientError) {
        self.instance = try .init(from: pieFed)
        
        // I suspect these can only be `nil` when the `PieFedSite` is used in a request body
        
        if let enableDownvotes = pieFed.enableDownvotes {
            self.downvotesEnabled = enableDownvotes
        } else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite downvotesEnabled")
        }
        
        if let userCount = pieFed.userCount {
            self.userCount = userCount
        } else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite userCount")
        }
        
        if let registrationMode = pieFed.registrationMode {
            self.registrationMode = .init(from: registrationMode)
        } else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite downvotesEnabled")
        }
        
        self.setup = true
        self.emailVerificationRequired = true
        self.isPrivate = false
        self.defaultTheme = "browser"
        self.legalInformation = nil
        self.hideModlogNames = true
        self.emailApplicationsToAdmins = true
        self.emailReportsToAdmins = false
        self.actorNameMaxLength = 20
        self.defaultFeed = .all
        self.slurFilterRegex = nil
        self.federationEnabled = true
        self.captchaDifficulty = .medium
        self.federationSignedFetch = nil
        self.defaultPostSortType = .hot
        self.defaultPostListingMode = .list
        
        // In theory we *could* grab these from the lemmy-compatible site
        self.nsfwContentEnabled = false
        self.communityCreationRestrictedToAdmins = false
        self.applicationQuestion = nil
        self.captchaEnabled = false
        
        let counts = lemmy.counts
        self.postCount = counts.posts
        self.commentCount = counts.comments
        self.communityCount = counts.communities
        self.activeUserCount = .init(
            sixMonths: counts.usersActiveHalfYear,
            month: counts.usersActiveMonth,
            week: counts.usersActiveWeek,
            day: counts.usersActiveDay
        )
    }
}
