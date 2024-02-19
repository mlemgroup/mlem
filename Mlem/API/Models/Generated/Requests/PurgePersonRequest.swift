//
//  PurgePersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PurgePersonRequest: APIPostRequest {
    typealias Body = APIPurgePerson
    typealias Response = APISuccessResponse

    let path = "/admin/purge/person"
    let body: Body?

    init(
        personId: Int,
        reason: String?
    ) {
        self.body = .init(
            personId: personId,
            reason: reason
        )
    }
}
