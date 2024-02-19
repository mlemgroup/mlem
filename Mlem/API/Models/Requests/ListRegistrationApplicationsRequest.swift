//
//  ListRegistrationApplicationsRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct ListRegistrationApplicationsRequest: APIGetRequest {
    typealias Response = APIListRegistrationApplicationsResponse

    let path = "/admin/registration_application/list"
    let queryItems: [URLQueryItem]

    init(
        unreadOnly: Bool?,
        page: Int?,
        limit: Int?
    ) {
        var request: APIListRegistrationApplications = .init(
            unread_only: unreadOnly,
            page: page,
            limit: limit
        )
        self.queryItems = request.toQueryItems()
    }
}
