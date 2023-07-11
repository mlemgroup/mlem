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
        account: SavedAccount,
        personId: Int,
        block: Bool
    ) {
        self.instanceURL = account.instanceLink
        self.body = .init(
            person_id: personId,
            block: block,
            auth: account.accessToken
        )
    }
}

// lemmy_api_common::user::BlockPersonResponse
struct BlockPersonResponse: Decodable {
    let personView: APIPersonView
    let blocked: Bool
}
