//
//  SharedTaskManager.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-27.
//

import Foundation

public class SharedTaskManager<Value> {
    var fetchTask: (() async throws -> Value)!
    
    private var ongoingTask: Task<Value, Error>?
    var fetchedValue: Value?
    
    init(fetchTask: (() async throws -> Value)? = nil) {
        self.fetchTask = fetchTask
    }
    
    @discardableResult
    public func getValue(task: Task<Value, Error>? = nil) async throws -> Value {
        if let fetchedValue {
            return fetchedValue
        } else {
            if let ongoingTask {
                let result = await ongoingTask.result
                return try result.get()
            } else {
                defer { ongoingTask = nil }
                let task = task ?? ongoingTask ?? Task { try await fetchTask() }
                ongoingTask = task
                let result = await task.result
                fetchedValue = try result.get()
                return try await fetchTask()
            }
        }
    }
}
