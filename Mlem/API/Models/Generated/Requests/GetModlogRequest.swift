//
//  GetModlogRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetModlogRequest: APIGetRequest {
    typealias Response = APIGetModlogResponse

    let path = "/modlog"
    let queryItems: [URLQueryItem]

    init(
        modPersonId: Int?,
        communityId: Int?,
        page: Int?,
        limit: Int?,
        type_: APIModlogActionType?,
        otherPersonId: Int?
    ) {
        self.queryItems = [
            .init(name: "mod_person_id", value: "\(modPersonId)"),
            .init(name: "community_id", value: "\(communityId)"),
            .init(name: "page", value: "\(page)"),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "type_", value: "\(type_)"),
            .init(name: "other_person_id", value: "\(otherPersonId)")
        ]
    }
}
