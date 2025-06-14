//
//  ApiClient+RegistrationApplication.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

public extension ApiClient {
    func getRegistrationApplicationCount() async throws -> Int {
        let response = try await performingForConnection { connection in
            try await connection.getRegistrationApplicationCount()
        }
        return response
    }
    
    func getRegistrationApplications(
        page: Int = 1,
        limit: Int = 20,
        unreadOnly: Bool = false
    ) async throws -> [RegistrationApplication] {
        let response = try await performingForConnection { connection in
            try await connection.getRegistrationApplications(
                page: page,
                limit: limit,
                unreadOnly: unreadOnly
            )
        }
        return await caches.registrationApplication.getModels(api: self, from: response)
    }
    
    @discardableResult
    func approveRegistrationApplication(
        id: Int,
        semaphore: UInt? = nil
    ) async throws -> RegistrationApplication {
        let response = try await performingForConnection { connection in
            try await connection.approveRegistrationApplication(id: id)
        }
        return await caches.registrationApplication.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func denyRegistrationApplication(
        id: Int,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> RegistrationApplication {
        let response = try await performingForConnection { connection in
            try await connection.denyRegistrationApplication(id: id, reason: reason)
        }
        return await caches.registrationApplication.getModel(
            api: self,
            from: response,
            semaphore: semaphore
        )
    }
}
