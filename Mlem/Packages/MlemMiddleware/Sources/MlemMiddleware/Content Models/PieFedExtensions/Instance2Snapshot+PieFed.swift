//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension Instance2Snapshot {
    init(pieFed: PieFedSite, lemmy: PieFedLemmyCompatibleSiteView) throws(ApiClientError) {
        // I suspect these can only be `nil` when the `PieFedSite` is used in a request body
        
        guard let enableDownvotes = pieFed.enableDownvotes else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite downvotesEnabled")
        }
        
        guard let userCount = pieFed.userCount else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite userCount")
        }
        
        guard let registrationMode = pieFed.registrationMode else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite downvotesEnabled")
        }

        let counts = lemmy.counts
        let activeUserCount: ActiveUserCount = .init(
            sixMonths: counts.usersActiveHalfYear,
            month: counts.usersActiveMonth,
            week: counts.usersActiveWeek,
            day: counts.usersActiveDay
        )

        try self.init(
            instance: .init(from: pieFed),
            setup: true,
            downvotesEnabled: enableDownvotes,
            nsfwContentEnabled: false,
            communityCreationRestrictedToAdmins: false,
            emailVerificationRequired: true,
            applicationQuestion: nil,
            isPrivate: false,
            defaultTheme: "browser",
            defaultFeed: .all,
            legalInformation: nil,
            hideModlogNames: true,
            emailApplicationsToAdmins: true,
            emailReportsToAdmins: false,
            slurFilterRegex: nil,
            actorNameMaxLength: 20,
            federationEnabled: true,
            captchaEnabled: false,
            captchaDifficulty: nil,
            registrationMode: .init(from: registrationMode),
            federationSignedFetch: nil,
            defaultPostListingMode: .list,
            defaultPostSortType: .hot,
            userCount: userCount,
            postCount: counts.posts,
            commentCount: counts.comments,
            communityCount: counts.communities,
            activeUserCount: activeUserCount
        )
    }
}
