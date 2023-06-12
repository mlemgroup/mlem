//
//  LoginRequest.swift
//  Mlem
//
//  Created by Nicholas Lawson on 05/06/2023.
//

import Foundation

struct LoginRequest: APIPostRequest {

    typealias Response = LoginResponse

    let instanceURL: URL
    let path = "user/login"
    let body: Body

    // lemmy_api_common::person::Login
    struct Body: Encodable {
        let username_or_email: String
        let password: String
    }

    init(instanceURL: URL, username: String, password: String) {
        self.instanceURL = instanceURL
        self.body = .init(username_or_email: username, password: password)
    }
}

struct LoginResponse: Decodable {
    let jwt: String
    let registrationCreated: Bool
    let verifyEmailSent: Bool
}
