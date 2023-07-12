//
//  APIErrorResponse.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

struct APIErrorResponse: Decodable {
    let error: String
}

private let possibleCredentialErrors = [
    "incorrect_password",
    "password_incorrect",
    "incorrect_login"
]

extension APIErrorResponse {
    var isIncorrectLogin: Bool { possibleCredentialErrors.contains(error) }
    var requires2FA: Bool { error == "missing_totp_token" }
    var isNotLoggedIn: Bool { error == "not_logged_in" }
}
