//
//  NewApiClient+User.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    func login(username: String, password: String, totpToken: String?) async throws -> ApiLoginResponse {
        let request = LoginRequest(
            usernameOrEmail: username,
            password: password,
            totp2faToken: totpToken
        )
        
        print(request)
        
        let response = try await perform(request)
        print(response)
        return response
    }
    
    func loadPerson(username: String) async throws -> ApiGetPersonDetailsResponse {
        let request = GetPersonDetailsRequest(
            personId: nil,
            username: username,
            sort: nil,
            page: nil,
            limit: nil,
            communityId: nil,
            savedOnly: nil
        )
        let response = try await perform(request)
        
        // TODO: return middleware
        return response
    }
}
