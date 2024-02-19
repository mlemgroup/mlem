//
//  GetModlogRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
        var request: APIGetModlog = .init(
            mod_person_id: modPersonId,
            community_id: communityId,
            page: page,
            limit: limit,
            type_: type_,
            other_person_id: otherPersonId
        )
        self.queryItems = request.toQueryItems()
    }
}
