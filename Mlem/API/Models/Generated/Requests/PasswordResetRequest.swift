//
//  PasswordResetRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct PasswordResetRequest: ApiPostRequest {
    typealias Body = ApiPasswordReset
    typealias Response = ApiSuccessResponse

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
