//
//  ContentCache.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

struct BaseCacheGroup {
    var community1: BaseContentCache<Community1> = .init()
    var community2: BaseContentCache<Community2> = .init()
    var community3: BaseContentCache<Community3> = .init()
    
    var user1: BaseContentCache<User1> = .init()
    var user2: BaseContentCache<User2> = .init()
    var user3: BaseContentCache<User3> = .init()
}

private struct WeakReference<Content: AnyObject> {
    weak var content: Content?
}


class CoreContentCache<Content: CoreModel> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func retrieveModel(actorId: URL) -> Content? {
        cachedItems.first(where: { $0.content?.actorId == actorId })?.content!
    }
    
    func createModel(for apiType: Content.APIType) -> Content {
        if let item = retrieveModel(actorId: apiType.actorId) {
            print("Using existing item for id \(apiType.actorId)")
            item.update(with: apiType, cascade: false)
            return item
        }
        print("Creating new item for id \(apiType.actorId)")
        let newItem = Content(from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}

class BaseContentCache<Content: BaseModel & AnyObject> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func retrieveModel(id: Content.APIType.ID) -> Content? {
        cachedItems.first(where: { $0.content?.id == id })?.content!
    }
    
    func retrieveModel(sourceInstance: NewInstanceStub, actorId: URL) -> Content? {
        cachedItems.first(
            where: { $0.content?.sourceInstance == sourceInstance && $0.content?.actorId == actorId }
        )?.content!
    }
    
    func createModel(sourceInstance: NewInstanceStub, for apiType: Content.APIType) -> Content {
        if let item = retrieveModel(id: apiType.id) {
            item.update(with: apiType, cascade: false)
            print("Using existing item for id \(apiType.id)")
            return item
        }
        print("Creating new item for id \(apiType.id)")
        let newItem = Content(sourceInstance: sourceInstance, from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}
