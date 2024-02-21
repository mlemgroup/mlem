//
//  EditSiteRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct EditSiteRequest: ApiPutRequest {
    typealias Body = ApiEditSite
    typealias Response = ApiSiteResponse

    let path = "/site"
    let body: Body?

    init(
        name: String?,
        sidebar: String?,
        description: String?,
        icon: URL?,
        banner: URL?,
        enableDownvotes: Bool?,
        enableNsfw: Bool?,
        communityCreationAdminOnly: Bool?,
        requireEmailVerification: Bool?,
        applicationQuestion: String?,
        privateInstance: Bool?,
        defaultTheme: String?,
        defaultPostListingType: ApiListingType?,
        legalInformation: String?,
        applicationEmailAdmins: Bool?,
        hideModlogModNames: Bool?,
        discussionLanguages: [Int]?,
        slurFilterRegex: String?,
        actorNameMaxLength: Int?,
        rateLimitMessage: Int?,
        rateLimitMessagePerSecond: Int?,
        rateLimitPost: Int?,
        rateLimitPostPerSecond: Int?,
        rateLimitRegister: Int?,
        rateLimitRegisterPerSecond: Int?,
        rateLimitImage: Int?,
        rateLimitImagePerSecond: Int?,
        rateLimitComment: Int?,
        rateLimitCommentPerSecond: Int?,
        rateLimitSearch: Int?,
        rateLimitSearchPerSecond: Int?,
        federationEnabled: Bool?,
        federationDebug: Bool?,
        captchaEnabled: Bool?,
        captchaDifficulty: String?,
        allowedInstances: [String]?,
        blockedInstances: [String]?,
        taglines: [String]?,
        registrationMode: ApiRegistrationMode?,
        reportsEmailAdmins: Bool?
    ) {
        self.body = .init(
            name: name,
            sidebar: sidebar,
            description: description,
            icon: icon,
            banner: banner,
            enableDownvotes: enableDownvotes,
            enableNsfw: enableNsfw,
            communityCreationAdminOnly: communityCreationAdminOnly,
            requireEmailVerification: requireEmailVerification,
            applicationQuestion: applicationQuestion,
            privateInstance: privateInstance,
            defaultTheme: defaultTheme,
            defaultPostListingType: defaultPostListingType,
            legalInformation: legalInformation,
            applicationEmailAdmins: applicationEmailAdmins,
            hideModlogModNames: hideModlogModNames,
            discussionLanguages: discussionLanguages,
            slurFilterRegex: slurFilterRegex,
            actorNameMaxLength: actorNameMaxLength,
            rateLimitMessage: rateLimitMessage,
            rateLimitMessagePerSecond: rateLimitMessagePerSecond,
            rateLimitPost: rateLimitPost,
            rateLimitPostPerSecond: rateLimitPostPerSecond,
            rateLimitRegister: rateLimitRegister,
            rateLimitRegisterPerSecond: rateLimitRegisterPerSecond,
            rateLimitImage: rateLimitImage,
            rateLimitImagePerSecond: rateLimitImagePerSecond,
            rateLimitComment: rateLimitComment,
            rateLimitCommentPerSecond: rateLimitCommentPerSecond,
            rateLimitSearch: rateLimitSearch,
            rateLimitSearchPerSecond: rateLimitSearchPerSecond,
            federationEnabled: federationEnabled,
            federationDebug: federationDebug,
            captchaEnabled: captchaEnabled,
            captchaDifficulty: captchaDifficulty,
            allowedInstances: allowedInstances,
            blockedInstances: blockedInstances,
            taglines: taglines,
            registrationMode: registrationMode,
            reportsEmailAdmins: reportsEmailAdmins
        )
    }
}
