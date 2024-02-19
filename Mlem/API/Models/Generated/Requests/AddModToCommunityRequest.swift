//
//  AddModToCommunityRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            communityId: communityId,
            personId: personId,
            added: added
        )
    }
}
