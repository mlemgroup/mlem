//
//  MarkReadQueue.swift
//
//
//  Created by Sjmarf on 29/05/2024.
//

import Foundation

actor MarkReadQueue {
    var ids: Set<Int> = .init()
    
    func popAll() -> Set<Int> {
        defer { ids.removeAll() }
        return ids
    }
    
    func add(_ postId: Int) {
        ids.insert(postId)
    }
    
    func remove(_ postId: Int) {
        ids.remove(postId)
    }
    
    func union(_ other: Set<Int>) {
        ids.formUnion(other)
    }
    
    func subtract(_ other: Set<Int>) {
        ids.subtract(other)
    }
}
