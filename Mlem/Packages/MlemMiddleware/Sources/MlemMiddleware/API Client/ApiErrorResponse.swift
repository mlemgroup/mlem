//
//  ApiErrorResponse.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

// TODO: 0.19 support add all the error types (https://github.com/LemmyNet/lemmy-js-client/blob/b2edfeeaffd189a51150362cc8ead03c65ee2652/src/types/LemmyErrorType.ts)

public struct ApiErrorResponse: Decodable {
    public let error: String
}

private let possibleCredentialErrors: Set<String> = [
    "incorrect_password",
    "password_incorrect",
    "incorrect_login",
    "couldnt_find_that_username_or_email"
]

private let possibleAuthenticationErrors: Set<String> = [
    "incorrect_password",
    "password_incorrect",
    "incorrect_login",
    "not_logged_in"
]

private let possible2FAErrors: Set<String> = [
    "missing_totp_token",
    "incorrect_totp_token"
]

private let couldntFindObjectErrors: Set<String> = [
    "couldnt_find_person",
    "couldnt_find_object"
]

public extension ApiErrorResponse {
    var requires2FA: Bool { possible2FAErrors.contains(error) }
    var isNotLoggedIn: Bool { possibleAuthenticationErrors.contains(error) }
    var instanceIsPrivate: Bool { error == "instance_is_private" }
    var registrationApplicationIsPending: Bool { error == "registration_application_is_pending" }
    var emailNotVerified: Bool { error == "email_not_verified" }
    var couldntFindObject: Bool { couldntFindObjectErrors.contains(error) }
    var notModOrAdmin: Bool { error == "not_a_mod_or_admin" }
    var notAdmin: Bool { error == "not_an_admin" }
}
