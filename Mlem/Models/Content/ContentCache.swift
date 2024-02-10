//
//  ContentCache.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

struct BaseCacheGroup {
    var community1: BaseCacheGroup<CommunityMantle1> = .init()
    var community2: BaseCacheGroup<CommunityMantle2> = .init()
}

private struct WeakReference<Content: AnyObject> {
    weak var content: Content?
}

class ContentStubCache<Content: ContentStub & AnyObject> {
    private var cachedItems: [WeakReference<Content>] = .init()
    func createModel(for hashValue: Int) -> Content? {
        return cachedItems.first(where: { $0.content.hashValue == hashValue })?.content!
    }
}

class CoreContentCache<Content: CoreModel> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func createModel(for apiType: Content.APIType) -> Content {
        if let item = cachedItems.first(where: { $0.content?.actorId == apiType.actorId }) {
            print("Using existing item for id \(apiType.actorId)")
            return item.content!
        }
        print("Creating new item for id \(apiType.actorId)")
        let newItem = Content(from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}

class MantleContentCache<Content: BaseModel & AnyObject> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func createModel(sourceInstance: NewInstanceStub, for apiType: Content.APIType) -> Content {
        if let item = cachedItems.first(where: { $0.content?.id == apiType.id }) {
            print("Using existing item for id \(apiType.id)")
            return item.content!
        }
        print("Creating new item for id \(apiType.id)")
        let newItem = Content(sourceInstance: sourceInstance, from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}
