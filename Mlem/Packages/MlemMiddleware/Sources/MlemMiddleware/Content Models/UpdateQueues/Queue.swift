//
//  Queue.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-04.
//

public class Queue<T> {
    private var items: [T] = .init()
    
    var numItems: Int { items.count }
    
    func enqueue(_ item: T) {
        items.append(item)
    }
    
    @discardableResult
    func dequeue() -> T? {
        guard !items.isEmpty else { return nil }
        return items.removeFirst()
    }
    
    func next() -> T? { items.first }
}
