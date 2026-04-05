//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Instance2Snapshot {
    init(from site: LemmySiteView) throws(ApiClientError) {
        let nsfwContentEnabled: Bool
        if let blockNsfw = site.localSite.nsfwContentDisallowed {
            nsfwContentEnabled = !blockNsfw
        } else if let enableNsfw = site.localSite.enableNsfw {
            nsfwContentEnabled = enableNsfw
        } else {
            throw .responseMissingRequiredData("ApiSiteView enableNsfw")
        }
        
        let userCount: Int
        let postCount: Int
        let commentCount: Int
        let communityCount: Int
        let activeUserCount: ActiveUserCount

        if let counts = site.counts {
            userCount = counts.users
            postCount = counts.posts
            commentCount = counts.comments
            communityCount = counts.communities
            activeUserCount = .init(
                sixMonths: counts.usersActiveHalfYear,
                month: counts.usersActiveMonth,
                week: counts.usersActiveWeek,
                day: counts.usersActiveDay
            )
        } else {
            guard let users = site.localSite.users else { throw .responseMissingRequiredData("LemmySiteView users") }
            userCount = users
            guard let posts = site.localSite.posts else { throw .responseMissingRequiredData("LemmySiteView posts") }
            postCount = posts
            guard let comments = site.localSite.comments else { throw .responseMissingRequiredData("LemmySiteView comments") }
            commentCount = comments
            guard let communities = site.localSite.communities else { throw .responseMissingRequiredData("LemmySiteView communities") }
            communityCount = communities
            guard let sixMonths = site.localSite.usersActiveHalfYear else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let month = site.localSite.usersActiveMonth else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let week = site.localSite.usersActiveWeek else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            guard let day = site.localSite.usersActiveDay else {
                throw .responseMissingRequiredData("LemmySiteView active users")
            }
            activeUserCount = .init(
                sixMonths: sixMonths,
                month: month,
                week: week,
                day: day
            )
        }

        let voteFederationMode: VoteFederationMode
        if let commentDownvotes = site.localSite.commentDownvotes,
            let commentUpvotes = site.localSite.commentUpvotes,
            let postDownvotes = site.localSite.postDownvotes,
            let postUpvotes = site.localSite.postUpvotes
        {
            voteFederationMode = .init(
                postUpvote: .init(from: postUpvotes),
                postDownvote: .init(from: postDownvotes),
                commentUpvote: .init(from: commentUpvotes),
                commentDownvote: .init(from: commentDownvotes)
            )
        } else if let enableDownvotes = site.localSite.enableDownvotes {
            voteFederationMode = enableDownvotes ? .all : .downvotesDisabled
        } else {
            throw .responseMissingRequiredData("LemmySiteView downvoteFederationMode")
        }

        try self.init(
            instance: .init(from: site.site),
            setup: site.localSite.siteSetup,
            voteFederationMode: voteFederationMode,
            nsfwContentEnabled: nsfwContentEnabled,
            communityCreationRestrictedToAdmins: site.localSite.communityCreationAdminOnly,
            emailVerificationRequired: site.localSite.requireEmailVerification ?? true,
            applicationQuestion: site.localSite.applicationQuestion,
            isPrivate: site.localSite.privateInstance,
            defaultTheme: site.localSite.defaultTheme,
            defaultFeed: .init(from: site.localSite.defaultPostListingType),
            legalInformation: site.localSite.legalInformation,
            hideModlogNames: site.localSite.hideModlogModNames ?? true, // Always hidden in Lemmy 1.0
            emailApplicationsToAdmins: site.localSite.applicationEmailAdmins,
            emailReportsToAdmins: site.localSite.reportsEmailAdmins,
            slurFilterRegex: site.localSite.slurFilterRegex,
            actorNameMaxLength: site.localSite.actorNameMaxLength ?? 20,
            federationEnabled: site.localSite.federationEnabled,
            captchaEnabled: site.localSite.captchaEnabled ?? false,
            captchaDifficulty: site.localSite.captchaDifficulty.map(CaptchaDifficulty.init) ?? .none,
            registrationMode: .init(from: site.localSite.registrationMode),
            federationSignedFetch: site.localSite.federationSignedFetch,
            defaultPostListingMode: site.localSite.defaultPostListingMode.map { .init(from: $0) },
            defaultPostSortType: site.localSite.defaultSortType.map { .init($0) },
            userCount: userCount,
            postCount: postCount,
            commentCount: commentCount,
            communityCount: communityCount,
            activeUserCount: activeUserCount
        )
    }
}
