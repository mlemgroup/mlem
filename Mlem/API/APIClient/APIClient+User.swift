//
//  NewAPIClient+User.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension APIClient {
    func login(username: String, password: String, totpToken: String?) async throws -> APILoginResponse {
        let request = LoginRequest(
            usernameOrEmail: username,
            password: password,
            totp2faToken: totpToken
        )
        
        return try await perform(request: request)
    }
}
