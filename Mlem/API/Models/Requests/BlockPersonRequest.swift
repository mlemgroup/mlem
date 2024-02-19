//
//  BlockPersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct BlockPersonRequest: APIPostRequest {
    typealias Body = APIBlockPerson
    typealias Response = APIBlockPersonResponse

    let path = "/user/block"
    let body: Body?

    init(
        personId: Int,
        block: Bool
    ) {
        self.body = .init(
            person_id: personId,
            block: block
        )
    }
}
