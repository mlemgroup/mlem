//
//  PurgePersonRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            person_id: personId,
            reason: reason
        )
    }
}
