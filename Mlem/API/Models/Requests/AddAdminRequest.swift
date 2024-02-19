//
//  AddAdminRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

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
            person_id: personId,
            added: added
        )
    }
}
