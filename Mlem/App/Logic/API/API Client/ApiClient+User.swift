//
//  NewApiClient+User.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    // Returns a raw API type :(
    // Probably OK because it's part of onboarding, which is cursed and bootstrappy
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
    
    func loadPerson(username: String) async throws -> Person3 {
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
        
        return caches.person3.getModel(api: self, from: response)
    }
    
    /// Loads the currently authenticated user
    func loadUser() async throws -> UserStub {
        // TODO: should this cache? Implicitly via ApiClient?
        let request = GetSiteRequest()
        let response = try await perform(request)

        guard let user = response.myUser else {
            throw UserError.noUserInResponse
        }
        guard let token else {
            throw UserError.unauthenticated
        }
        
        let name = user.localUserView.person.name
        
        return .init(
            api: self,
            id: user.localUserView.localUser.id,
            name: name,
            actorId: parseActorId(instanceLink: response.actorId, name: name),
            accessToken: token,
            nickname: user.localUserView.person.displayName,
            cachedSiteVersion: .init(response.version),
            avatarUrl: user.localUserView.person.avatar,
            lastLoggedIn: Date.now
        )
    }
}
