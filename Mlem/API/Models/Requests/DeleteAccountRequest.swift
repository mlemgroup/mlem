//
//  DeleteAccountRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

struct DeleteAccountRequest: APIPostRequest {
    typealias Body = APIDeleteAccount
    typealias Response = APISuccessResponse

    let path = "/user/delete_account"
    let body: Body?

    init(
        password: String,
        deleteContent: Bool
    ) {
        self.body = .init(
            password: password,
            delete_content: deleteContent
        )
    }
}
