//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-29.
//

import Foundation

extension ModlogChildFetcher {
    class SharedCache {
        typealias TaskResponse = [ApiModlogActionType: [ModlogEntry]]
        var api: ApiClient
        let pageSize: Int
        var communityId: Int?
        var ongoingTask: Task<TaskResponse, Error>?
        
        init(api: ApiClient, pageSize: Int, communityId: Int?) {
            self.api = api
            self.pageSize = pageSize
            self.communityId = communityId
        }
        
        private func fetchItems() async throws -> TaskResponse {
            let response = try await api.getModlog(page: 1, limit: pageSize, communityId: communityId)
            return .init(grouping: response, by: { $0.type.type })
        }
        
        @MainActor
        func get(type: ApiModlogActionType) async throws -> [ModlogEntry] {
            let task: Task<TaskResponse, Error>
            if let ongoingTask {
                task = ongoingTask
            } else {
                task = Task { try await fetchItems() }
                ongoingTask = task
            }
            let response = try await task.result.get()
            return response[type] ?? []
        }
        
        @MainActor
        func reset() {
            ongoingTask = nil
        }
    }
}
