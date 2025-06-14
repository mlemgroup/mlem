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
        page: Int = 1,
        limit: Int = 20,
        unreadOnly: Bool = false
    ) async throws -> [RegistrationApplicationSnapshot] {
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
