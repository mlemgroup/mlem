//
//  PersonRepository.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Dependencies
import Foundation

enum PersonRequestError: Error {
    case notFound
}

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
    
    /// Gets the UserModel for a given user
    /// - Parameter id: id of the user to get
    /// - Returns: UserModel for the given user
    func loadUser(for id: Int) async throws -> UserModel {
        let response = try await apiClient.getPersonDetails(for: id, limit: 1, savedOnly: false)
        return UserModel(from: response.personView)
    }
    
    /// Gets full user details for the given user
    /// - Parameters:
    ///   - id: user id to get for
    ///   - limit: max number of content items to fetch
    ///   - savedOnly: if present, whether to fetch saved items; calling user must be the requested user
    /// - Returns: GetPersonDetailsResponse for the given user
    func loadUserDetails(for id: Int, limit: Int, savedOnly: Bool = false) async throws -> GetPersonDetailsResponse {
        try await apiClient.getPersonDetails(for: id, limit: limit, savedOnly: savedOnly)
    }
    
    func loadUserDetails(for url: URL, limit: Int, savedOnly: Bool = false) async throws -> GetPersonDetailsResponse {
        let result = try await apiClient.resolve(query: url.absoluteString)
        switch result {
        case .person(let person):
            return try await loadUserDetails(for: person.person.id, limit: limit, savedOnly: savedOnly)
        default:
            throw PersonRequestError.notFound
        }
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
    
    @discardableResult
    func updateBlocked(for personId: Int, blocked: Bool) async throws -> BlockPersonResponse {
        try await apiClient.blockPerson(id: personId, shouldBlock: blocked)
    }
}
