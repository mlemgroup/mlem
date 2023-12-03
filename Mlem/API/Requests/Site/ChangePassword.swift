//
//  ChangePassword.swift
//  Mlem
//
//  Created by Sjmarf on 03/12/2023.
//

import Foundation

// lemmy_api_common::site::GetSite
struct ChangePasswordRequest: APIPutRequest {
    typealias Response = LoginResponse

    let instanceURL: URL
    let path = "user/change_password"
    
    struct Body: Encodable {
        let auth: String
        
        let newPassword: String
        let newPasswordVerify: String
        let oldPassword: String
    }
    
    let body: Body

    init(
        session: APISession,
        newPassword: String,
        newPasswordVerify: String,
        oldPassword: String
    ) throws {
        self.instanceURL = try session.instanceUrl
        self.body = try .init(
            auth: session.token,
            newPassword: newPassword,
            newPasswordVerify: newPasswordVerify,
            oldPassword: oldPassword
        )
    }
}
