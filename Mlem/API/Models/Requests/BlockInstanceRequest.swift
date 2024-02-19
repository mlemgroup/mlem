//
//  BlockInstanceRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct BlockInstanceRequest: APIPostRequest {
    typealias Body = APIBlockInstance
    typealias Response = APIBlockInstanceResponse

    let path = "/site/block"
    let body: Body?

    init(
        instanceId: Int,
        block: Bool
    ) {
        self.body = .init(
            instance_id: instanceId,
            block: block
        )
    }
}
