//
//  ApiClient+Report.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

public extension ApiClient {
    func getPostReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        postId: Int? = nil
    ) async throws -> PagedResponse<Report> {
        let response = try await repository.getPostReports(
            pageInfo: pageInfo,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId,
            postId: postId
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        let reports = await caches.report.getModels(api: self, from: response.items, myPersonId: myPersonId)
        return .init(items: reports, nextLocation: response.nextLocation)
    }

    func getCommentReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false,
        communityId: Int? = nil,
        commentId: Int? = nil
    ) async throws -> PagedResponse<Report> {
        let response = try await repository.getCommentReports(
            pageInfo: pageInfo,
            unresolvedOnly: unresolvedOnly,
            communityId: communityId,
            commentId: commentId
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        let reports = await caches.report.getModels(api: self, from: response.items, myPersonId: myPersonId)
        return .init(items: reports, nextLocation: response.nextLocation)
    }

    func getMessageReports(
        pageInfo: PageInfo,
        unresolvedOnly: Bool = false
    ) async throws -> PagedResponse<Report> {
        let response = try await repository.getMessageReports(
            pageInfo: pageInfo,
            unresolvedOnly: unresolvedOnly
        )
        guard let myPersonId = try await myPersonId else { throw ApiClientError.notLoggedIn }
        let reports = await caches.report.getModels(api: self, from: response.items, myPersonId: myPersonId)
        return .init(items: reports, nextLocation: response.nextLocation)
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
