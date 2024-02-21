//
//  BanPersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct BanPersonRequest: ApiPostRequest {
    typealias Body = ApiBanPerson
    typealias Response = ApiBanPersonResponse

    let path = "/user/ban"
    let body: Body?

    init(
        personId: Int,
        ban: Bool,
        removeData: Bool?,
        reason: String?,
        expires: Int?
    ) {
        self.body = .init(
            personId: personId,
            ban: ban,
            removeData: removeData,
            reason: reason,
            expires: expires
        )
    }
}
