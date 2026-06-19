//
//  ApiRepository+RegistrationApplication.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-03.
//

extension ApiRepository {
    func getRegistrationApplicationCount() async throws -> Int {
        try await performingForConnection { connection in
            try await connection.getRegistrationApplicationCount()
        }
    }
    
    func getRegistrationApplications(
        pageInfo: PageInfo,
        unreadOnly: Bool = false
    ) async throws -> PagedResponse<RegistrationApplicationSnapshot> {
        try await performingForConnection { connection in
            try await connection.getRegistrationApplications(
                pageInfo: pageInfo,
                unreadOnly: unreadOnly
            )
        }
    }
    
    func approveRegistrationApplication(id: Int) async throws -> RegistrationApplicationSnapshot {
        try await performingForConnection { connection in
            try await connection.approveRegistrationApplication(id: id)
        }
    }
    
    func denyRegistrationApplication(
        id: Int,
        reason: String?
    ) async throws -> RegistrationApplicationSnapshot {
        try await performingForConnection { connection in
            try await connection.denyRegistrationApplication(id: id, reason: reason)
        }
    }
}
