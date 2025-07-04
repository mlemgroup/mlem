//
//  ApiClient+Report.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

public extension ApiClient {
    func getPostReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> [Report] {
        let snapshot = try await repository.getPostReports(
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId,
            postId: postId
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModels(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    func getCommentReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> [Report] {
        let snapshot = try await repository.getCommentReports(
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId,
            commentId: commentId
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModels(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    func getMessageReports(
        page: Int = 1,
        limit: Int = 20,
        unresolvedOnly: Bool = false
    ) async throws -> [Report] {
        let snapshot = try await repository.getMessageReports(
            page: page,
            limit: limit,
            unresolvedOnly: unresolvedOnly
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModels(
            api: self,
            from: snapshot,
            myPersonId: myPersonId
        )
    }
    
    @discardableResult
    func resolvePostReport(
        id: Int,
        resolved: Bool,
        semaphore: UInt? = nil
    ) async throws -> Report {
        let snapshot = try await repository.resolvePostReport(id: id, resolved: resolved)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func resolveCommentReport(
        id: Int,
        resolved: Bool,
        semaphore: UInt? = nil
    ) async throws -> Report {
        let snapshot = try await repository.resolveCommentReport(id: id, resolved: resolved)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func resolveMessageReport(
        id: Int,
        resolved: Bool,
        semaphore: UInt? = nil
    ) async throws -> Report {
        let snapshot = try await repository.resolveMessageReport(id: id, resolved: resolved)
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        return await caches.report.getModel(
            api: self,
            from: snapshot,
            myPersonId: myPersonId,
            semaphore: semaphore
        )
    }
}
