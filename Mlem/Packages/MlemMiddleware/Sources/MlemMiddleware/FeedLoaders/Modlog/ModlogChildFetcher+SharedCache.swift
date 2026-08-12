//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-29.
//

import Foundation

extension ModlogChildFetcher {
    class SharedCache {
        struct TaskResponse {
            var entries: [ModlogEntryType: [ModlogEntry]]
            var nextLocation: PageLocation
        } 

        var api: ApiClient
        let pageSize: Int
        var communityId: Int?
        var targetPersonId: Int?
        var moderatorPersonId: Int?
        var ongoingTask: Task<TaskResponse, Error>?
        
        init(api: ApiClient, pageSize: Int, communityId: Int?) {
            self.api = api
            self.pageSize = pageSize
            self.communityId = communityId
        }
        
        private func fetchItems() async throws -> TaskResponse {
            let response = try await api.getModlog(
                pageInfo: .init(cursor: .first, limit: pageSize),
                communityId: communityId,
                moderatorId: moderatorPersonId,
                subjectPersonId: targetPersonId
            )
            return .init(
                entries: .init(grouping: response.items, by: { $0.type.type }),
                nextLocation: response.nextLocation
            )
        }
        
        @MainActor
        func get(type: ModlogEntryType) async throws -> PagedResponse<ModlogEntry> {
            let task: Task<TaskResponse, Error>
            if let ongoingTask {
                task = ongoingTask
            } else {
                task = Task { try await fetchItems() }
                ongoingTask = task
            }
            let response = try await task.result.get()
            return .init(
                items: response.entries[type] ?? [],
                nextLocation: response.nextLocation
            )
        }
        
        @MainActor
        func reset() {
            ongoingTask = nil
        }
    }
}
