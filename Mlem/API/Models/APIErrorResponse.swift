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
    "incorrect_login",
    "couldnt_find_that_username_or_email"
]

private let possible2FAErrors = [
    "missing_totp_token",
    "incorrect_totp_token"
]

extension APIErrorResponse {
    var isIncorrectLogin: Bool { possibleCredentialErrors.contains(error) }
    var requires2FA: Bool { possible2FAErrors.contains(error) }
    var isNotLoggedIn: Bool { error == "not_logged_in" }
}
