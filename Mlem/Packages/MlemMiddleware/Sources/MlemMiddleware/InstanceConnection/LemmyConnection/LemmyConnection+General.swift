//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension LemmyConnection {
    func getVersionFallback() async throws -> SiteVersion {
        let response = try await performingForEndpoint { endpoint in
            LemmyFallbackGetVersionRequest(endpoint: endpoint)
        }
        return response.version
    }

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
                totp2faToken: totpToken,
                stayLoggedIn: true
            )
        }
        
        // I actually don't think this is necessary - the login endpoint seems to throw these errors itself.
        // I suspect that `registrationCreated` and `verifyEmailSent` can only be true for the `LemmyLoginResponse`
        // that is returned when signing in. Nevertheless, I've included this just in case.
        if response.registrationCreated {
            throw ApiClientError.applicationPending
        }
        if response.verifyEmailSent {
            throw ApiClientError.emailNotVerified
        }
        
        guard let jwt = response.jwt else {
            assertionFailure()
            throw ApiClientError.responseMissingRequiredData("getAccountToken jwt")
        }
        return jwt
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        let username = try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyGetSiteRequest(endpoint: endpoint)
                let response = try await self.perform(request, tokenOverride: token, endpoint: .v3)
                return response.myUser?.localUserView.person.name
            case .v4:
                let request = LemmyGetMyUserRequest()
                let response = try await self.perform(request, tokenOverride: token, endpoint: .v4)
                return response.localUserView.person.name
            }
        }
        if let username {
            return username
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
                endpoint: endpoint,
                username: username,
                password: password,
                passwordVerify: confirmPassword,
                showNsfw: showNsfw,
                email: email,
                captchaUuid: captcha?.id.uuidString,
                captchaAnswer: captchaAnswer,
                honeypot: nil,
                answer: applicationQuestionResponse,
                stayLoggedIn: true,
                token: nil
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
                oldPassword: oldPassword,
                stayLoggedIn: true
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
        // Fix for https://github.com/mlemgroup/mlem/issues/2341
        let components = url.pathComponents
        if url.host == baseUrl.host(), components.count > 2 {
            switch components[1] {
            case "c":
                let response = try await performingForEndpoint { endpoint in
                    LemmyGetCommunityRequest(endpoint: endpoint, id: nil, name: components[2])
                }
                return try .community(.init(from: response.communityView))
            case "u":
                let response = try await performingForEndpoint { endpoint in
                    LemmyReadPersonRequest(
                        endpoint: endpoint,
                        personId: nil,
                        username: components[2],
                        sort: nil,
                        page: 1,
                        limit: 1,
                        communityId: nil,
                        savedOnly: nil
                    )
                }
                return try .person(.init(from: response.personView))
            default:
                break
            }
        }

        let response = try await performingForEndpoint { endpoint in
            LemmyResolveObjectRequest(endpoint: endpoint, q: url.absoluteString)
        }
        return try .init(from: response)
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [String]) {
        let myUser = try await processingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
                let request = LemmyGetSiteRequest(endpoint: .v3)
                let response = try await self.perform(request, endpoint: .v3)
                return response.myUser
            case .v4:
                let request = LemmyGetMyUserRequest()
                let response = try await self.perform(request, endpoint: .v4)
                return response
            }
        }
        
        guard let myUser else { return ([], [], []) }

        let instances: [String]
        if let blocks = myUser.instanceCommunitiesBlocks {
            instances = blocks.map(\.domain)
        } else if let blocks = myUser.instanceBlocks {
            instances = blocks.map(\.instance.domain)
        } else {
            throw ApiClientError.responseMissingRequiredData("Lemmy getBlocked instances")
        }
        
        return try (
            people: myUser.personBlocks.map { try .init(from: $0.person) },
            communities: myUser.communityBlocks.map { try .init(from: $0.community) },
            instances: instances
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
                type_: type?.lemmyApiType,
                otherPersonId: subjectPersonId,
                postId: postId,
                commentId: commentId,
                listingType: .all,
                showBulk: nil,
                bulkActionParentId: nil,
                pageCursor: nil
            )
        }
        switch response {
        case let .lemmyGetModlogResponse(response):
            return try response.toSnapshots()
        case let .lemmyPagedResponse(response):
            return try response.items.compactMap { try .init(from: $0) }
        }
    }
    
    func getPostLink(url: URL) async throws -> PostLink {
        let response = try await performingForEndpoint { endpoint in
            LemmyGetLinkMetadataRequest(endpoint: endpoint, url: url)
        }
        return .init(
            content: url,
            thumbnail: response.metadata.image,
            label: response.metadata.title ?? url.absoluteString
        )
    }
}
