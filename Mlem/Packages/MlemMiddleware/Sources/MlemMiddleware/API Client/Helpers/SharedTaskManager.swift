//
//  SharedTaskManager.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-27.
//

import Foundation

public class SharedTaskManager<Value, TaskResponse> {
    var fetchTask: (() async throws -> TaskResponse)!
    var createValue: ((TaskResponse) -> Value)!
    
    var ongoingTask: Task<TaskResponse, Error>?
    var fetchedValue: Value?
    
    init(
        fetchTask: (() async throws -> TaskResponse)? = nil,
        createValue: ((TaskResponse) -> Value)? = nil
    ) {
        self.fetchTask = fetchTask
        self.createValue = createValue
    }
    
    @discardableResult
    public func getValue(task: Task<TaskResponse, Error>? = nil) async throws -> Value {
        if let fetchedValue {
            return fetchedValue
        } else {
            if let ongoingTask {
                let result = await ongoingTask.result
                return try createValue(result.get())
            } else {
                defer { ongoingTask = nil }
                let task = task ?? ongoingTask ?? Task { try await fetchTask() }
                ongoingTask = task
                let result = await task.result
                fetchedValue = try createValue(result.get())
                return try await createValue(fetchTask())
            }
        }
    }
}
