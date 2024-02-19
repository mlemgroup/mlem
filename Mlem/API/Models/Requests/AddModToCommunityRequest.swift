//
//  AddModToCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct AddModToCommunityRequest: APIPostRequest {
    typealias Body = APIAddModToCommunity
    typealias Response = APIAddModToCommunityResponse

    let path = "/community/mod"
    let body: Body?

    init(
        communityId: Int,
        personId: Int,
        added: Bool
    ) {
        self.body = .init(
            community_id: communityId,
            person_id: personId,
            added: added
        )
    }
}
