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
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        throw ApiClientError.unsupportedLemmyVersion
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
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    @discardableResult
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getCaptcha() async throws -> Captcha {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func resolve(url: URL) async throws -> ResolvedContent {
        throw ApiClientError.unsupportedLemmyVersion
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot]) {
        throw ApiClientError.unsupportedLemmyVersion
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
        throw ApiClientError.unsupportedLemmyVersion
    }
}
