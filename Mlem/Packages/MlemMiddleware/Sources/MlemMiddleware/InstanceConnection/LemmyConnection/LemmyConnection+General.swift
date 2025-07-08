//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension LemmyConnection {
    func getAccountToken(
        usernameOrEmail: String,
        password: String,
        totpToken: String?
    ) async throws -> String {
        let response = try await performingForEndpoint { endpoint in
            LemmyLoginRequest(
                endpoint: endpoint,
                usernameOrEmail: usernameOrEmail,
                password: password,
                totp2faToken: totpToken
            )
        }
        
        // I actually don't think this is necessary - the login endpoint seems to throw these errors itself.
        // I suspect that `registrationCreated` and `verifyEmailSent` can only be true for the `LemmyLoginResponse`
        // that is returned when signing in. Nevertheless, I've included this just in case.
        if response.registrationCreated {
            throw ApiClientError.response(.init(error: "registration_application_is_pending"), 200)
        }
        if response.verifyEmailSent {
            throw ApiClientError.response(.init(error: "email_not_verified"), 200)
        }
        
        guard let jwt = response.jwt else {
            assertionFailure()
            throw ApiClientError.responseMissingRequiredData("getAccountToken jwt")
        }
        return jwt
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        let response = try await processingForEndpoint { endpoint in
            let request = LemmyGetSiteRequest(endpoint: endpoint)
            return try await perform(request, tokenOverride: token)
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
    ) async throws -> SignUpResponse {
        let response = try await performingForEndpoint { endpoint in
            LemmyRegisterRequest(
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
        return .init(from: response)
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String {
        let response = try await performingForEndpoint { endpoint in
            LemmyChangePasswordRequest(
                endpoint: endpoint,
                newPassword: newPassword,
                newPasswordVerify: confirmNewPassword,
                oldPassword: oldPassword
            )
        }
        guard let token = response.jwt else {
            assertionFailure()
            throw ApiClientError.responseMissingRequiredData("changePassword jwt")
        }
        return token
    }
    
    func getCaptcha() async throws -> Captcha {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetCaptchaRequest(endpoint: endpoint)
        }
        guard let info = response.ok,
              let uuid = UUID(uuidString: info.uuid),
              let data = Data(base64Encoded: info.png)
        else { throw ApiClientError.unsuccessful }
        
        return .init(id: uuid, imageData: data)
    }
    
    func resolve(url: URL) async throws -> ResolvedContent {
        let response = try await performingForEndpoint { endpoint in
            LemmyResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
        }
        return try .init(from: response)
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot]) {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetSiteRequest(endpoint: endpoint)
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
        type: ModlogEntryType? = nil
    ) async throws -> [ModlogEntrySnapshot] {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetModLogRequest(
                endpoint: endpoint,
                modPersonId: moderatorId,
                communityId: communityId,
                page: page,
                limit: limit,
                type_: type?.apiType ?? .all,
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
