//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-07.
//

import Foundation

public extension PieFedConnection {
    func getAccountToken(
        usernameOrEmail: String,
        password: String,
        totpToken: String?
    ) async throws -> String {
        throw ApiClientError.featureUnsupported
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot]) {
        throw ApiClientError.featureUnsupported
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
        throw ApiClientError.featureUnsupported
    }
}
