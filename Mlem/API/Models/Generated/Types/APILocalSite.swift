//
//  APILocalSite.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// LocalSite.ts
struct APILocalSite: Codable {
    let id: Int
    let siteId: Int
    let siteSetup: Bool
    let enableDownvotes: Bool
    let enableNsfw: Bool
    let communityCreationAdminOnly: Bool
    let requireEmailVerification: Bool
    let applicationQuestion: String?
    let privateInstance: Bool
    let defaultTheme: String
    let defaultPostListingType: APIListingType
    let legalInformation: String?
    let hideModlogModNames: Bool
    let applicationEmailAdmins: Bool
    let slurFilterRegex: String?
    let actorNameMaxLength: Int
    let federationEnabled: Bool
    let captchaEnabled: Bool
    let captchaDifficulty: String
    let published: Date
    let updated: Date?
    let registrationMode: APIRegistrationMode
    let reportsEmailAdmins: Bool
    let federationSignedFetch: Bool?
}
