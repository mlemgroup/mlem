//
//  ApiRepository+General.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-02.
//

import Foundation

extension ApiRepository {
    func getAccountToken(usernameOrEmail: String, password: String, totpToken: String?) async throws -> String {
        try await performingForConnection { connection in
            try await connection.getAccountToken(
                usernameOrEmail: usernameOrEmail,
                password: password,
                totpToken: totpToken
            )
        }
    }
    
    func getUsernameFromToken(token: String) async throws -> String {
        try await performingForConnection { connection in
            try await connection.getUsernameFromToken(token: token)
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
    ) async throws -> SignUpResponse {
        try await performingForConnection { connection in
            try await connection.signUp(
                username: username,
                password: password,
                confirmPassword: confirmPassword,
                showNsfw: showNsfw,
                email: email,
                captcha: captcha,
                captchaAnswer: captchaAnswer,
                applicationQuestionResponse: applicationQuestionResponse
            )
        }
    }
    
    func changePassword(
        newPassword: String,
        confirmNewPassword: String,
        oldPassword: String
    ) async throws -> String {
        try await performingForConnection { connection in
            try await connection.changePassword(
                newPassword: newPassword,
                confirmNewPassword: confirmNewPassword,
                oldPassword: oldPassword
            )
        }
    }
    
    func getCaptcha() async throws -> Captcha {
        try await performingForConnection { connection in
            try await connection.getCaptcha()
        }
    }
    
    func resolve(url: URL) async throws -> ResolvedContent {
        try await performingForConnection { connection in
            try await connection.resolve(url: url)
        }
    }
    
    func getBlocked() async throws -> (people: [Person1Snapshot], communities: [Community1Snapshot], instances: [Instance1Snapshot]) {
        try await performingForConnection { connection in
            try await connection.getBlocked()
        }
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
        try await performingForConnection { connection in
            try await connection.getModlog(
                page: page,
                limit: limit,
                communityId: communityId,
                moderatorId: moderatorId,
                subjectPersonId: subjectPersonId,
                postId: postId,
                commentId: commentId,
                type: type
            )
        }
    }
    
    func getPostLink(url: URL) async throws -> PostLink {
        try await performingForConnection { connection in
            try await connection.getPostLink(url: url)
        }
    }
}
