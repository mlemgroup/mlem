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

private let possibleAuthenticationErrors = [
    "incorrect_password",
    "password_incorrect",
    "incorrect_login",
    "not_logged_in"
]

private let possible2FAErrors = [
    "missing_totp_token",
    "incorrect_totp_token"
]

private let registrationErrors = [
    "registration_application_pending",
    "email_not_verified"
]

extension APIErrorResponse {
    // var isIncorrectLogin: Bool { possibleCredentialErrors.contains(error) }
    var requires2FA: Bool { possible2FAErrors.contains(error) }
    var isNotLoggedIn: Bool { possibleAuthenticationErrors.contains(error) }
    var userRegistrationPending: Bool { registrationErrors.contains(error) }
    var emailNotVerified: Bool { registrationErrors.contains(error) }
    var instanceIsPrivate: Bool { error == "instance_is_private" }
}
