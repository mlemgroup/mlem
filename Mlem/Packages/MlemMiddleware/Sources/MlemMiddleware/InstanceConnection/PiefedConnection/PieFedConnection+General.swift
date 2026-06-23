//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension PieFedConnection {
    func getVersionFallback() async throws -> SiteVersion {
        let request = PieFedFallbackGetVersionRequest()
        let response = try await perform(request)
        return response.version
    }

    func getAccountToken(
        usernameOrEmail: String,
        password: String,
        totpToken: String?
    ) async throws -> String {
        if totpToken != nil {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedUserLoginRequest(username: usernameOrEmail, password: password)
        let response = try await perform(request)
        return response.jwt
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        let request = PieFedGetSiteRequest()
        let response = try await perform(request, tokenOverride: token)
        if let name = response.myUser?.localUserView.person.userName {
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
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String {
        throw ApiClientError.featureUnsupported
    }
    
    func getCaptcha() async throws -> Captcha {
        throw ApiClientError.featureUnsupported
    }
    
    func resolve(url: URL) async throws -> ResolvedContent {
        let request = PieFedResolveObjectRequest(q: url.absoluteString)
        let response = try await perform(request)
        return try .init(from: response)
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [String]) {
        let request = PieFedGetSiteRequest()
        let response = try await perform(request)
        guard let myUser = response.myUser else { return ([], [], []) }
        
        return try (
            people: myUser.personBlocks.map { try .init(from: $0.target) },
            communities: myUser.communityBlocks.map { try .init(from: $0.community) },
            instances: myUser.instanceBlocks.map(\.instance.domain)
        )
    }
    
    func getModlog(
        pageInfo: PageInfo,
        communityId: Int? = nil,
        moderatorId: Int? = nil,
        subjectPersonId: Int? = nil,
        postId: Int? = nil,
        commentId: Int? = nil,
        type: ModlogEntryType? = nil
    ) async throws -> PagedResponse<ModlogEntrySnapshot> {
        let request = PieFedGetModlogRequest(
            modPersonId: moderatorId,
            communityId: communityId,
            page: try pageInfo.cursor.requirePageNumber,
            limit: pageInfo.limit,
            type_: type?.piefedApiType,
            otherPersonId: subjectPersonId,
            postId: postId,
            commentId: commentId
        )
        let response = try await perform(request)
        return try .fromPieFed(
            pageInfo: pageInfo,
            items: try response.toSnapshots()
        )
    }
    
    func getPostLink(url: URL) async throws -> PostLink {
        guard try await self.supports(.fetchLinkMetadata) else {
            throw ApiClientError.featureUnsupported
        }
        let request = PieFedGetSiteMetadataRequest(url: url.absoluteString)
        let response = try await perform(request)
        guard let imageUrl = response.metadata.image.map(URL.init(string:)) else {
            throw ApiClientError.unsuccessful
        }
        return .init(
            content: url,
            thumbnail: imageUrl,
            label: response.metadata.title ?? url.absoluteString
        )
    }
}
