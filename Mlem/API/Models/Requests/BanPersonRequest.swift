//
//  BanPersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct BanPersonRequest: APIPostRequest {
    typealias Body = APIBanPerson
    typealias Response = APIBanPersonResponse

    let path = "/user/ban"
    let body: Body?

    init(
        personId: Int,
        ban: Bool,
        removeData: Bool,
        reason: String,
        expires: Int
    ) {
        self.body = .init(
            person_id: personId,
            ban: ban,
            remove_data: removeData,
            reason: reason,
            expires: expires
        )
    }
}
