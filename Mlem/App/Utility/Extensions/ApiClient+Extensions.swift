//
//  ApiClient+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/06/2024.
//

import MlemMiddleware

extension ApiClient {
    var isActive: Bool {
        if token == nil {
            return AppState.main.guestSession.api === self
        }
        return !AppState.main.activeSessions.allSatisfy { $0.api !== self }
    }
}