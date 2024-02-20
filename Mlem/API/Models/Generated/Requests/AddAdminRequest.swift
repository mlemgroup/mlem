//
//  AddAdminRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct AddAdminRequest: APIPostRequest {
    typealias Body = APIAddAdmin
    typealias Response = APIAddAdminResponse

    let path = "/admin/add"
    let body: Body?

    init(
        personId: Int,
        added: Bool
    ) {
        self.body = .init(
            personId: personId,
            added: added
        )
    }
}
