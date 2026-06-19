//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

internal extension LemmyConnection {
    func getRegistrationApplicationCount() async throws -> Int {
        let response = try await performingForEndpoint { endpoint in
            switch endpoint {
            case .v3:
            LemmyGetUnreadRegistrationApplicationCountRequest()
            case .v4:
                throw ApiClientError.featureUnsupported
            }
        }
        return response.registrationApplications
    }
    
    func getRegistrationApplications(
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<RegistrationApplicationSnapshot> {
        let response = try await performingForEndpoint { endpoint in
            LemmyListRegistrationApplicationsRequest(
                endpoint: endpoint,
                unreadOnly: unreadOnly,
                page: pageInfo.cursor.pageNumber,
                limit: pageInfo.limit,
                pageCursor: pageInfo.cursor.cursorString
            )
        }
        return try .fromLemmyV3(
            pageInfo: pageInfo,
            items: try response.items.map { try .init(from: $0) },
            nextCursor: response.nextPage
        )
    }
    
    @discardableResult
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyApproveRegistrationApplicationRequest(
                endpoint: endpoint,
                id: id,
                approve: true,
                denyReason: nil
            )
        }
        return try .init(from: response.registrationApplication)
    }
    
    @discardableResult
    func denyRegistrationApplication(id: Int, reason: String?) async throws -> RegistrationApplicationSnapshot {
        let response = try await performingForEndpoint { endpoint in
            LemmyApproveRegistrationApplicationRequest(
                endpoint: endpoint,
                id: id,
                approve: false,
                denyReason: reason
            )
        }
        return try .init(from: response.registrationApplication)
    }
}
