//
//  NewAPIClient+User.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension APIClient {
    func login(username: String, password: String, totpToken: String?) async throws -> LoginResponse {
        let request = LoginRequest(
            username: username,
            password: password,
            totpToken: totpToken
        )
        
        return try await perform(request: request)
    }
}
