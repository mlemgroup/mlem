//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension LemmyConnection {
    func getAccountToken(usernameOrEmail: String, password: String, totpToken: String?) async throws -> ApiLoginResponse {
        let response = try await performingForEndpoint { endpoint in
            LoginRequest(
                endpoint: endpoint,
                usernameOrEmail: usernameOrEmail,
                password: password,
                totp2faToken: totpToken
            )
        }
        return response
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        let response = try await processingForEndpoint { endpoint in
            let request = GetSiteRequest(endpoint: endpoint)
            return try await perform(request, tokenOverride: token, ignoreLocalCache: true)
        }
        if let name = response.myUser?.localUserView.person.name {
            return name
        }
        throw ApiClientError.notLoggedIn
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
        let response = try await performingForEndpoint { endpoint in
            RegisterRequest(
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
        }
        return response
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> ApiLoginResponse {
        let response = try await performingForEndpoint { endpoint in
            ChangePasswordRequest(
                endpoint: endpoint,
                newPassword: newPassword,
                newPasswordVerify: confirmNewPassword,
                oldPassword: oldPassword
            )
        }
        return response
    }
    
    func getCaptcha() async throws -> Captcha {
        let response = try await performingForEndpoint { endpoint in
            GetCaptchaRequest(endpoint: endpoint)
        }
        guard let info = response.ok,
              let uuid = UUID(uuidString: info.uuid),
              let data = Data(base64Encoded: info.png)
        else { throw ApiClientError.unsuccessful }
        
        return .init(id: uuid, imageData: data)
    }
    
    func resolve(url: URL) async throws -> ResolvedContent {
        let response = try await performingForEndpoint { endpoint in
            ResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
        }
        return try .init(from: response)
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot]) {
        let response = try await performingForEndpoint { endpoint in
            GetSiteRequest(endpoint: endpoint)
        }
        
        guard let myUser = response.myUser else { return ([], [], []) }
        
        return try (
            people: myUser.personBlocks.map { try .init(from: $0.target) },
            communities: myUser.communityBlocks.map { try .init(from: $0.community) },
            instances: myUser.instanceBlocks.compactMap(\.site).map { try .init(from: $0) }
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
    ) async throws -> [ModlogEntrySnapshot] {
        let response = try await performingForEndpoint { endpoint in
            GetModLogRequest(
                endpoint: endpoint,
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
        }
        return try response.toSnapshots()
    }
}
