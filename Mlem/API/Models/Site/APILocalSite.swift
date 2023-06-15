//
//  APILocalSite.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import Foundation

// lemmy_db_schema::source::local_site::LocalSite
struct APILocalSite: Decodable {
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
    let defaultPostListingType: String
    let legalInformation: String?
    let hideModlogModNames: Bool
    let applicationEmailAdmins: Bool
    let slurFilterRegex: String?
    let actorMaxNameLength: Int
    let federationEnabled: Bool
    let federationDebug: Bool
    let federationWorkerCount: Int
    let captchaEnabled: Bool
    let captchaDifficulty: String
    let registrationMode: APIRegistrationMode
    let reportsEmailAdmins: Bool
    let published: Date
    let updated: Date?
}

// lemmy_db_schema::source::local_site::RegistrationMode
enum APIRegistrationMode: String, Codable
{
    case closed = "Closed"
    case requireApplication = "RequireApplication"
    case open = "Open"
}
