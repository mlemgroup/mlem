//
//  BanPerson.swift
//  Mlem
//
//  Created by Sjmarf on 27/01/2024.
//

import Foundation

struct BanPersonRequest: APIPostRequest {
    typealias Response = BanPersonResponse

    let instanceURL: URL
    let path = "user/ban"
    let body: Body

    struct Body: Encodable {
        let personId: Int
        let ban: Bool
        let expires: Int?
        let reason: String?
        let removeData: Bool
        let auth: String
    }

    init(
        session: APISession,
        personId: Int,
        ban: Bool,
        expires: Int?,
        reason: String?,
        removeData: Bool
    ) throws {
        self.instanceURL = try session.instanceUrl

        self.body = try .init(
            personId: personId,
            ban: ban,
            expires: expires,
            reason: reason,
            removeData: removeData,
            auth: session.token
        )
    }
}

struct BanPersonResponse: Decodable {
    let banned: Bool
    let personView: APIPersonView
}
