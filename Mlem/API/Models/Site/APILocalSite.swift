//
//  APILocalSite.swift
//  Mlem
//
//  Created by Jonathan de Jong on 12/06/2023.
//

import SwiftUI

enum APICaptchaDifficulty: String, Codable { case easy, medium, hard }

// lemmy_db_schema::source::local_site::LocalSite
struct APILocalSite: Decodable {
//    let id: Int
//    let siteId: Int
//    let siteSetup: Bool
    let enableDownvotes: Bool
    let enableNsfw: Bool
    let communityCreationAdminOnly: Bool
    let requireEmailVerification: Bool
//    let applicationQuestion: String?
    let privateInstance: Bool
//    let defaultTheme: String
    let defaultPostListingType: APIListingType
//    let legalInformation: String?
    let hideModlogModNames: Bool
    let applicationEmailAdmins: Bool
    let slurFilterRegex: String?
//    let actorNameMaxLength: Int
    let federationEnabled: Bool
    let federationSignedFetch: Bool?
    let captchaEnabled: Bool
    let captchaDifficulty: APICaptchaDifficulty
    let registrationMode: APIRegistrationMode
    let reportsEmailAdmins: Bool
    let published: Date
//    let updated: Date?
}

// lemmy_db_schema::source::local_site::RegistrationMode
enum APIRegistrationMode: String, Codable {
    case closed = "closed"
    case requireApplication = "requireapplication"
    case open = "open"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            if let item = APIRegistrationMode(rawValue: stringValue.lowercased()) {
                self = item
                return
            }
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid APIRegistrationMode value")
    }
    
    var label: String {
        switch self {
        case .requireApplication:
            return "Requires Application"
        default:
            return rawValue.capitalized
        }
    }
    
    var color: Color {
        switch self {
        case .closed:
            return .red
        case .requireApplication:
            return .yellow
        case .open:
            return .green
        }
    }
}
