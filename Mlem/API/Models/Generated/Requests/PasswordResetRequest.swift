//
//  PasswordResetRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PasswordResetRequest: APIPostRequest {
    typealias Body = APIPasswordReset
    typealias Response = APISuccessResponse

    let path = "/user/password_reset"
    let body: Body?

    init(
        email: String
    ) {
        self.body = .init(
            email: email
        )
    }
}
