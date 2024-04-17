//
//  BlockInstance.swift
//  Mlem
//
//  Created by Sjmarf on 16/04/2024.
//

import Foundation

struct BlockInstanceRequest: APIPostRequest {
    typealias Response = BlockInstanceResponse

    let instanceURL: URL
    let path = "site/block"
    let body: Body

    // lemmy_api_common::community::BlockCommunity
    struct Body: Encodable {
        let instance_id: Int
        let block: Bool

        let auth: String
    }

    init(
        session: APISession,
        instanceId: Int,
        block: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            instance_id: instanceId,
            block: block,
            auth: session.token
        )
    }
}

struct BlockInstanceResponse: Decodable {
    let blocked: Bool
}
