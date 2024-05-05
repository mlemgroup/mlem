//
//  ModlogTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Dependencies
import Foundation
import Semaphore
import SwiftUI

class ModlogTracker: ParentTracker<ModlogEntry> {
    var initialItems: [ModlogEntry]?
    
    private let initialLoadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    func getPreloadedItems(for actionType: ModlogAction, instanceUrl: URL?, communityId: Int?) async throws -> [ModlogEntry]? {
        @Dependency(\.apiClient) var apiClient
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
    
        // only one thread at a time--this ensures that the initial load is only performed once. Subsequent threads calling this method will await the semaphore and fall into the first block.
        await initialLoadingSemaphore.wait()
        defer { initialLoadingSemaphore.signal() }
        
        // if initial load has already been performed, simply return items
        if let initialItems {
            return initialItems.filter { $0.action == actionType }
        }
        
        // otherwise load items
        let newItems = try await apiClient.getModlog(
            for: instanceUrl,
            communityId: communityId,
            page: 1,
            limit: internetSpeed.pageSize,
            type: nil
        )
        initialItems = newItems
        return newItems.filter { $0.action == actionType }
    }
}
