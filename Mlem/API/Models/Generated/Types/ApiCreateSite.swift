//
//  ApiCreateSite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CreateSite.ts
struct ApiCreateSite: Codable {
    let name: String
    let sidebar: String?
    let description: String?
    let icon: URL?
    let banner: URL?
    let enableDownvotes: Bool?
    let enableNsfw: Bool?
    let communityCreationAdminOnly: Bool?
    let requireEmailVerification: Bool?
    let applicationQuestion: String?
    let privateInstance: Bool?
    let defaultTheme: String?
    let defaultPostListingType: ApiListingType?
    let legalInformation: String?
    let applicationEmailAdmins: Bool?
    let hideModlogModNames: Bool?
    let discussionLanguages: [Int]?
    let slurFilterRegex: String?
    let actorNameMaxLength: Int?
    let rateLimitMessage: Int?
    let rateLimitMessagePerSecond: Int?
    let rateLimitPost: Int?
    let rateLimitPostPerSecond: Int?
    let rateLimitRegister: Int?
    let rateLimitRegisterPerSecond: Int?
    let rateLimitImage: Int?
    let rateLimitImagePerSecond: Int?
    let rateLimitComment: Int?
    let rateLimitCommentPerSecond: Int?
    let rateLimitSearch: Int?
    let rateLimitSearchPerSecond: Int?
    let federationEnabled: Bool?
    let federationDebug: Bool?
    let captchaEnabled: Bool?
    let captchaDifficulty: String?
    let allowedInstances: [String]?
    let blockedInstances: [String]?
    let taglines: [String]?
    let registrationMode: ApiRegistrationMode?
}
