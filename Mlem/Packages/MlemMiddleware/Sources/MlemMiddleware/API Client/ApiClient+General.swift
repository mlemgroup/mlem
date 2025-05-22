//
//  ApiClient+General.swift
//
//
//  Created by Sjmarf on 25/06/2024.
//

import Foundation

public extension ApiClient {
    var isAdmin: Bool {
        myInstance?.administrators.contains(where: { $0.id == myPerson?.id }) ?? false
    }
    
    /// Returns true if both myPerson and the given person are admins on this instance and myPerson outranks the given person, false otherwise
    func isHigherAdmin(than person: any Person1Providing) -> Bool {
        guard person.api.actorId == actorId,
              let myPerson,
              let myAdminIndex = myInstance?.administrators.firstIndex(of: myPerson.person2),
              let targetAdminIndex = myInstance?.administrators.firstIndex(where: { $0.actorId == person.actorId }) else {
            return false
        }
        return myAdminIndex < targetAdminIndex
    }
    
    // Returns a raw API type :(
    // Probably OK because it's part of onboarding, which is cursed and bootstrappy
    func getAccountToken(usernameOrEmail: String, password: String, totpToken: String?) async throws -> ApiLoginResponse {
        let request = LoginRequest(
            endpoint: .v3,
            usernameOrEmail: usernameOrEmail,
            password: password,
            totp2faToken: totpToken
        )
        return try await perform(request, requiresToken: false)
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        let request = GetSiteRequest(endpoint: .v3)
        let response = try await perform(request, tokenOverride: token)
        if let name = response.myUser?.localUserView.person.name {
            return name
        }
        throw ApiClientError.notLoggedIn
    }
    
    func login(password: String, totpToken: String?) async throws {
        guard let username else { throw ApiClientError.notLoggedIn }
        let response = try await getAccountToken(usernameOrEmail: username, password: password, totpToken: totpToken)
        if let jwt = response.jwt {
            updateToken(jwt)
        } else {
            throw ApiClientError.unsuccessful
        }
    }
    
    func signUp(
        username: String,
        password: String,
        confirmPassword: String,
        showNsfw: Bool,
        email: String?,
        captcha: Captcha?,
        captchaAnswer: String?,
        applicationQuestionResponse: String?
    ) async throws -> ApiLoginResponse {
        let request = RegisterRequest(
            endpoint: .v3,
            username: username,
            password: password,
            passwordVerify: confirmPassword,
            showNsfw: showNsfw,
            email: email,
            captchaUuid: captcha?.id.uuidString,
            captchaAnswer: captchaAnswer,
            honeypot: nil,
            answer: applicationQuestionResponse
        )
        return try await perform(request)
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> ApiLoginResponse {
        let request = ChangePasswordRequest(
            endpoint: .v3,
            newPassword: newPassword,
            newPasswordVerify: confirmNewPassword,
            oldPassword: oldPassword
        )
        let response = try await perform(request)
        if let token = response.jwt {
            updateToken(token)
        }
        return response
    }
    
    func getCaptcha() async throws -> Captcha {
        let request = GetCaptchaRequest(endpoint: .v3)
        let response = try await perform(request)
        
        guard let info = response.ok,
              let uuid = UUID(uuidString: info.uuid),
              let data = Data(base64Encoded: info.png)
        else { throw ApiClientError.unsuccessful }
        
        return .init(id: uuid, imageData: data)
    }
    
    /// Returns an object associated with the given URL.
    ///
    /// ## Overview
    ///
    /// The backend performs two steps to do this:
    /// 1) Check it already has the given actorId mapped in the database, in which case it returns the entity.
    /// 2) If the entity is not present in the database, it contacts the URL host to ask for it, then returns it back to us.
    ///   When this happens, the call will take longer to resolve.
    ///
    /// **Importantly, step 2) is only performed if the `ApiClient` is authenticated.**
    ///
    func resolve(url: URL) async throws -> (any ActorIdentifiable & Sharable) {
        let request = ResolveObjectRequest(endpoint: .v3, q: url.absoluteString)
        let response = try await perform(request)
        if let post = response.post {
            return try await caches.post2.getModel(
                api: self,
                from: .init(from: post)
            )
        }
        if let comment = response.comment {
            return try await caches.comment2.getModel(
                api: self,
                from: .init(from: comment)
            )
        }
        if let person = response.person {
            return try await caches.person2.getModel(
                api: self,
                from: .init(from: person)
            )
        }
        if let community = response.community {
            return try await caches.community2.getModel(
                api: self,
                from: .init(from: community)
            )
        }
        throw ApiClientError.noEntityFound
    }
    
    func resolve<Value: ActorIdentifiable & Sharable>(urls: [URL]) async throws -> [URL: Value] {
        try await withThrowingTaskGroup(of: (url: URL, value: Value)?.self) { group in
            for url in urls {
                group.addTask {
                    if let value = try await self.resolve(url: url) as? Value {
                        return (url, value)
                    }
                    return nil
                }
            }
            
            var collected: [URL: Value] = .init()
            
            for try await result in group {
                if let result {
                    collected[result.url] = result.value
                }
            }
            
            return collected
        }
    }
    
    func getBlocked() async throws -> (people: [Person1], communities: [Community1], instances: [Instance1]) {
        let request = GetSiteRequest(endpoint: .v3)
        let response = try await perform(request)
        
        guard let myUser = response.myUser else { return ([], [], []) }
        
        return try await (
            people: caches.person1.getModels(
                api: self,
                from: myUser.personBlocks.map { try .init(from: $0.target) }
            ),
            communities: caches.community1.getModels(
                api: self,
                from: myUser.communityBlocks.map { try .init(from: $0.community) }
            ),
            instances: caches.instance1.getModels(
                api: self,
                from: myUser.instanceBlocks.compactMap(\.site).map { try .init(from: $0) }
            )
        )
    }
    
    func getModlog(
        page: Int = 1,
        limit: Int = 20,
        communityId: Int? = nil,
        moderatorId: Int? = nil,
        subjectPersonId: Int? = nil,
        postId: Int? = nil,
        commentId: Int? = nil,
        type: ApiModlogActionType = .all
    ) async throws -> [ModlogEntry] {
        let request = GetModLogRequest(
            endpoint: .v3,
            modPersonId: moderatorId,
            communityId: communityId,
            page: page,
            limit: limit,
            type_: type,
            otherPersonId: subjectPersonId,
            postId: postId,
            commentId: commentId,
            listingType: nil,
            pageCursor: nil,
            pageBack: nil
        )
        let response = try await perform(request)
        return try await createModlogEntries(response.toSnapshots())
    }
    
    @MainActor
    private func createModlogEntries(_ entries: [ModlogEntrySnapshot]) -> [ModlogEntry] {
        entries.map { entry in
            ModlogEntry(
                api: self,
                created: entry.created,
                moderator: caches.person1.getOptionalModel(
                    api: self,
                    from: entry.moderator
                ),
                moderatorId: entry.moderatorId,
                type: .init(from: entry.type, api: self)
            )
        }
    }
}
