//
//  ChangePasswordRequest.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

struct ChangePasswordRequest: APIPutRequest {
    typealias Body = APIChangePassword
    typealias Response = APILoginResponse

    let path = "/user/change_password"
    let body: Body?

    init(
        newPassword: String,
        newPasswordVerify: String,
        oldPassword: String
    ) {
        self.body = .init(
            newPassword: newPassword,
            newPasswordVerify: newPasswordVerify,
            oldPassword: oldPassword
        )
    }
}
