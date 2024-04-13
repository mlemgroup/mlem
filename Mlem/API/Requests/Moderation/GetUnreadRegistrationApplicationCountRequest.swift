//
//  GetUnreadRegistrationApplicationCountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// swiftlint:disable:next type_name
struct GetUnreadRegistrationApplicationCountRequest: APIGetRequest {
    typealias Response = APIGetUnreadRegistrationApplicationCountResponse

    let instanceURL: URL
    let path = "admin/registration_application/count"
    let queryItems: [URLQueryItem]

    init(session: APISession) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "auth", value: session.token)
        ]
    }
}

// GetUnreadRegistrationApplicationCountResponse.ts
// swiftlint:disable:next type_name
struct APIGetUnreadRegistrationApplicationCountResponse: Decodable {
    let registrationApplications: Int
}
