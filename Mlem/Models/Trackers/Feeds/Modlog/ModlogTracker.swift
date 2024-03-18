//
//  ModlogTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-14.
//

import Dependencies
import Foundation
import SwiftUI
import Semaphore

class ModlogTracker: ParentTracker<ModlogEntry>, ModlogTrackerProtocol {
    var initialItems: [ModlogEntry]?
    
    private let initialLoadingSemaphore: AsyncSemaphore = .init(value: 1)
    
    func getPreloadedItems(for actionType: ModlogAction, instanceUrl: URL?, communityId: Int?) async throws -> [ModlogEntry]? {
        @Dependency(\.apiClient) var apiClient
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        
        await initialLoadingSemaphore.wait()
        defer { initialLoadingSemaphore.signal() }
        
        if let initialItems {
            return initialItems.filter { $0.action == actionType }
            
        }
        
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
