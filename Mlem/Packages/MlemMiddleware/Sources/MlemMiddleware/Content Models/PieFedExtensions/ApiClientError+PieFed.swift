//
//  ApiClientError+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-01.
//

import Foundation

extension ApiClientError {
    init(piefedMessage: String, statusCode: Int) {
        self = switch piefedMessage {
        default:
            .response(piefedMessage, statusCode)
        }
    }
}
