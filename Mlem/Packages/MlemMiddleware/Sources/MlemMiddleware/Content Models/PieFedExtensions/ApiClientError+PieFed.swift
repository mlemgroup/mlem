//
//  ApiClientError+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-01.
//

import Foundation

extension ApiClientError {
    init(piefedMessage: String, statusCode: Int, hasToken: Bool) {
        self = switch piefedMessage {
        case "incorrect_login":
            hasToken ? .invalidSession : .notLoggedIn
        case "No object found.":
            .noEntityFound
        default:
            .response(piefedMessage, statusCode)
        }
    }
}
