//
//  Queue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

internal class Queue<T> {
    private var items: [T] = .init()
    
    public func enqueue(_ item: T) {
        items.append(item)
    }
    
    @discardableResult
    public func dequeue() -> T? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
    }
    
    public func next() -> T? {
        return items.first
    }
}
