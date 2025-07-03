//
//  ApiClient+RegistrationApplication.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

public extension ApiClient {
    func getRegistrationApplicationCount() async throws -> Int {
        try await repository.getRegistrationApplicationCount()
    }
    
    func getRegistrationApplications(
        page: Int = 1,
        limit: Int = 20,
        unreadOnly: Bool = false
    ) async throws -> [RegistrationApplication] {
        let snapshot = try await repository.getRegistrationApplications(
            page: page,
            limit: limit,
            unreadOnly: unreadOnly
        )
        return await caches.registrationApplication.getModels(api: self, from: snapshot)
    }
    
    @discardableResult
    func approveRegistrationApplication(
        id: Int,
        semaphore: UInt? = nil
    ) async throws -> RegistrationApplication {
        let snapshot = try await repository.approveRegistrationApplication(id: id)
        return await caches.registrationApplication.getModel(
            api: self,
            from: snapshot,
            semaphore: semaphore
        )
    }
    
    @discardableResult
    func denyRegistrationApplication(
        id: Int,
        reason: String?,
        semaphore: UInt? = nil
    ) async throws -> RegistrationApplication {
        let snapshot = try await repository.denyRegistrationApplication(id: id, reason: reason)
        return await caches.registrationApplication.getModel(
            api: self,
            from: snapshot,
            semaphore: semaphore
        )
    }
}
