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
    
    var person1: BaseContentCache<Person1> = .init()
    var person2: BaseContentCache<Person2> = .init()
    var person3: BaseContentCache<Person3> = .init()
    
    var post1: BaseContentCache<Post1> = .init()
    var post2: BaseContentCache<Post2> = .init()
    
    func clean() {
        community1.clean()
        community2.clean()
        community3.clean()
        person1.clean()
        person2.clean()
        person3.clean()
        post1.clean()
        post2.clean()
    }
}

struct WeakReference<Content: AnyObject> {
    weak var content: Content?
}

class CoreContentCache<Content: CoreModel> {
    private var cachedItems: [URL: WeakReference<Content>] = .init()
    
    func retrieveModel(actorId: URL) -> Content? {
        cachedItems[actorId]?.content
    }
    
    func createModel(for apiType: Content.ApiType) -> Content {
        if let item = retrieveModel(actorId: apiType.actorId) {
            print("Using existing item for id \(apiType.actorId)")
            item.update(with: apiType)
            return item
        }
        print("Creating new item for id \(apiType.actorId)")
        let newItem = Content(from: apiType)
        cachedItems[apiType.actorId] = .init(content: newItem)
        return newItem
    }
    
    /// Remove dead references
    func clean() {
        for (key, value) in cachedItems where value.content == nil {
            print("Removed value with id \(key)")
            cachedItems[key] = nil
        }
    }
}

class BaseContentCache<Content: ContentModel & AnyObject> {
    private var cachedItems: [Content.ID: WeakReference<Content>] = .init()
    
    func retrieveModel(id: Content.ApiType.ID) -> Content? {
        cachedItems[id]?.content
    }
    
    func createModel(source: any ApiSource, for apiType: Content.ApiType) -> Content {
        if let item = retrieveModel(id: apiType.id) {
            item.update(with: apiType)
            print("Using existing item for id \(apiType.id)")
            return item
        }
        print("Creating new item for id \(apiType.id)")
        let newItem = Content(source: source, from: apiType)
        cachedItems[apiType.id] = .init(content: newItem)
        return newItem
    }
    
    /// Remove dead references
    func clean() {
        for (key, value) in cachedItems where value.content == nil {
            print("Removed value with id \(key)")
            cachedItems[key] = nil
        }
    }
}
