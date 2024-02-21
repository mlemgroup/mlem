//
//  GetModlogRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct GetModlogRequest: ApiGetRequest {
    typealias Response = ApiGetModlogResponse

    let path = "/modlog"
    let queryItems: [URLQueryItem]

    init(
        modPersonId: Int?,
        communityId: Int?,
        page: Int?,
        limit: Int?,
        type_: ApiModlogActionType?,
        otherPersonId: Int?
    ) {
        self.queryItems = [
            .init(name: "mod_person_id", value: modPersonId.map(String.init)),
            .init(name: "community_id", value: communityId.map(String.init)),
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "type_", value: type_?.rawValue),
            .init(name: "other_person_id", value: otherPersonId.map(String.init))
        ]
    }
}
