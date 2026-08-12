//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-08.
//

import Foundation

public extension PieFedConnection {
    func getRegistrationApplicationCount() async throws -> Int {
        throw ApiClientError.featureUnsupported
    }
    
    func getRegistrationApplications(
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<RegistrationApplicationSnapshot> {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot {
        throw ApiClientError.featureUnsupported
    }
    
    @discardableResult
    func denyRegistrationApplication(id: Int, reason: String?) async throws -> RegistrationApplicationSnapshot {
        throw ApiClientError.featureUnsupported
    }
}
