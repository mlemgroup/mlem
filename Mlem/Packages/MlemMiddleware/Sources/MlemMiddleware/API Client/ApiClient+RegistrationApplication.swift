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
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<RegistrationApplication> {
        let response = try await repository.getRegistrationApplications(
            pageInfo: pageInfo,
            unreadOnly: unreadOnly
        )
        let applications = await caches.registrationApplication.getModels(api: self, from: response.items)
        return .init(items: applications, nextLocation: response.nextLocation)
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
