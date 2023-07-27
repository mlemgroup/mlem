//
//  PersonRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Foundation
import Dependencies

class PersonRepository {
    @Dependency(\.apiClient) private var apiClient
    
    // TODO: move person logic into here--out of scope for unread counts PR
    
    func getUnreadCounts() async throws -> APIPersonUnreadCounts {
        do {
            return try await apiClient.getUnreadCount()
        } catch {
            throw error
        }
    }
    
    func markAllAsRead() async throws {
        do {
            try await apiClient.markAllAsRead()
        } catch {
            throw error
        }
    }
}
