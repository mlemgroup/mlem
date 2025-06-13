//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension LemmyConnection {
    func getRegistrationApplicationCount() async throws -> Int {
        let response = try await performingForEndpoint { endpoint in
            GetUnreadRegistrationApplicationCountRequest(endpoint: endpoint)
        }
        return response.registrationApplications
    }
    
    func getRegistrationApplications(
        page: Int = 1,
        limit: Int = 20,
        unreadOnly: Bool = false
    ) async throws -> [RegistrationApplicationSnapshot] {
        let response = try await performingForEndpoint { endpoint in
            ListRegistrationApplicationsRequest(
                endpoint: endpoint,
                unreadOnly: unreadOnly,
                page: page,
                limit: limit,
                pageCursor: nil,
                pageBack: nil
            )
        }
        return try response.registrationApplications.map { try .init(from: $0) }
    }
    
    @discardableResult
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot {
        let response = try await performingForEndpoint { endpoint in
            ApproveRegistrationApplicationRequest(
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
            ApproveRegistrationApplicationRequest(
                endpoint: endpoint,
                id: id,
                approve: false,
                denyReason: reason
            )
        }
        return try .init(from: response.registrationApplication)
    }
}
