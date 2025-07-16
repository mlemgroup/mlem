//
//  Queue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

public class Queue<T> {
    private var items: [T] = .init()
    
    internal var numItems: Int { items.count }
    
    internal func enqueue(_ item: T) {
        items.append(item)
    }
    
    @discardableResult
    internal func dequeue() -> T? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
    }
    
    internal func next() -> T? { items.first }
}
