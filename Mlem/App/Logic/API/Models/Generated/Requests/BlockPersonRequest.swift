//
//  BlockPersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct BlockPersonRequest: ApiPostRequest {
    typealias Body = ApiBlockPerson
    typealias Response = ApiBlockPersonResponse

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
