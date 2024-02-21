//
//  BlockInstanceRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct BlockInstanceRequest: ApiPostRequest {
    typealias Body = ApiBlockInstance
    typealias Response = ApiBlockInstanceResponse

    let path = "/site/block"
    let body: Body?

    init(
        instanceId: Int,
        block: Bool
    ) {
        self.body = .init(
            instanceId: instanceId,
            block: block
        )
    }
}
