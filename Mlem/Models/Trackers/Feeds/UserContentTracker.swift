//
//  UserContentTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Dependencies
import Foundation

/// Class that tracks user content (i.e., posts and comments). This is a `StandardTracekr` and not a multi-tracker because both posts and comments come from a single API call
class UserContentTracker: StandardTracker<UserContentModel> {
    @Dependency(\.personRepository) var personRepository
    
    /// Optional because userId is not guaranteed to be resolved, so we need a dummy state. Trying to use the tracker will cause assertionFailures; it is the responsibility of the views using this class to ensure that it is not used with no user id.
    private var userId: Int?
    /// True when this is tracking saved items, false otherwise
    let saved: Bool
    
    init(internetSpeed: InternetSpeed, userId: Int?, saved: Bool) {
        self.userId = userId
        self.saved = saved
        
        super.init(internetSpeed: internetSpeed)
    }
    
    func updateUserId(to newId: Int) async throws {
        guard newId != userId else { return }
        
        userId = newId
        await clear()
    }
    
    // MARK: StandardTracker functions
    
    override func fetchPage(page: Int) async throws -> FetchResponse<UserContentModel> {
        guard let userId else {
            assertionFailure("fetchPage called with nil userId")
            return .init(items: .init(), cursor: nil, numFiltered: 0)
        }
        
        let items = try await personRepository.loadUserContent(for: userId, page: page, limit: internetSpeed.pageSize, saved: saved)
        return .init(items: items, cursor: nil, numFiltered: 0)
    }
    
    // No cursor tracking available so fetchCursor is not implemented
}
