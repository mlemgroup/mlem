//
//  BlockPersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

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
            personId: personId,
            block: block
        )
    }
}
