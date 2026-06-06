//
//  ApiClientError+Lemmy.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-01.
//

import Foundation

extension ApiClientError {
    init(lemmyMessage: String, statusCode: Int) {
        self = switch lemmyMessage {
        case "incorrect_password",
             "password_incorrect",
             "incorrect_login",
             "not_logged_in",
             "couldnt_find_that_username_or_email":
            .notLoggedIn
        case "missing_totp_token",
             "incorrect_totp_token":
            .missingTotp
        case "couldnt_find_person",
             "couldnt_find_object",
             "No object found.":
            .noEntityFound
        case "instance_is_private":
            .instanceIsPrivate
        case "registration_application_is_pending":
            .applicationPending
        case "email_not_verified":
            .emailNotVerified
        case "not_mod_or_admin":
            .notModOrAdmin
        case "not_admin",
             "not_an_admin":
            .notAdmin
        case "invalid_password":
            .newPasswordInvalid
        default:
            .response(lemmyMessage, statusCode)
        }
    }
}
