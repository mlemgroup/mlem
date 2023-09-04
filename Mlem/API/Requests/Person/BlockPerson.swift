//
//  BlockPerson.swift
//  Mlem
//
//  Created by Weston Hanners on 7/10/23.
//

import Foundation

struct BlockPersonRequest: APIPostRequest {
    typealias Response = BlockPersonResponse

    let instanceURL: URL
    let path = "user/block"
    let body: Body

    // lemmy_api_common::user::BlockPerson
    struct Body: Encodable {
        let person_id: Int
        let block: Bool
        let auth: String
    }

    init(
        session: APISession,
        personId: Int,
        block: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            person_id: personId,
            block: block,
            auth: session.token
        )
    }
}

// lemmy_api_common::user::BlockPersonResponse
struct BlockPersonResponse: Decodable {
    let personView: APIPersonView
    let blocked: Bool
}
