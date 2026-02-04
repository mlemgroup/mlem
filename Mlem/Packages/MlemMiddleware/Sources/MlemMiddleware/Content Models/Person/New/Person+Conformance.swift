//
//  Person+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-26.
//

// MARK: ContentModel

public extension Person {
    static var tierNumber: Int { 4 }
}

// MARK: CacheIdentifiable

public extension Person {
    var cacheId: Int { id }
}

// MARK: Blockable

public extension Person {
    func updateBlocked(_ newValue: Bool) {
        blocked = newValue
        
        Task {
            await updateQueue.addItem {
                await .init(api: self.api, snapshot: .person2(try await self.api.repository.blockPerson(id: self.id, block: newValue)))
            }
        }
    }
}
