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
    func updateBlocked(_ newValue: Bool, callback: ((Bool) -> Void)? = nil) {
        blocked = newValue
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.blockPerson(id: self.id, block: newValue)
                    callback?(true)
                    return await .init(api: self.api, snapshot: .person2(snapshot))
                } catch {
                    callback?(false)
                    throw error
                }
            }
        }
    }
}
