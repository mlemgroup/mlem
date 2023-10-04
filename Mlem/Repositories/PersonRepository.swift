//
//  PersonRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Dependencies
import Foundation

class PersonRepository {
    @Dependency(\.apiClient) private var apiClient
    
    // TODO: move person logic into here--out of scope for unread counts PR
    
    func search(
        query: String,
        page: Int,
        limit: Int
    ) async throws -> [UserModel] {
        let users = try await apiClient.performSearch(
            query: query,
            searchType: .users,
            sortOption: .topAll,
            listingType: .all,
            page: page,
            limit: limit
        ).users.map { UserModel(from: $0) }
        return users
    }
    
    func loadDetails(for id: Int) async throws -> UserModel {
        let response = try await apiClient.getPersonDetails(for: id, limit: 1, savedOnly: false)
        return UserModel(from: response.personView)
    }
    
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
