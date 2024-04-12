//
//  ListRegistrationApplicationsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

struct ListRegistrationApplicationsRequest: APIGetRequest {
    typealias Response = APIListRegistrationApplicationsResponse

    let instanceURL: URL
    let path = "admin/registration_application/list"
    let queryItems: [URLQueryItem]

    init(
        session: APISession,
        unreadOnly: Bool?,
        page: Int?,
        limit: Int?
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.queryItems = try [
            .init(name: "unread_only", value: unreadOnly.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "auth", value: session.token)
        ]
    }
}

struct APIListRegistrationApplicationsResponse: Decodable {
    let registrationApplications: [APIRegistrationApplicationView]
}
