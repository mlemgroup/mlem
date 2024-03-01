//
//  ContentCache.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

struct BaseCacheGroup {
    var community1: ContentCache<Community1> = .init()
    var community2: ContentCache<Community2> = .init()
    var community3: ContentCache<Community3> = .init()
    
    var person1: ContentCache<Person1> = .init()
    var person2: ContentCache<Person2> = .init()
    var person3: ContentCache<Person3> = .init()
    
    var post1: ContentCache<Post1> = .init()
    var post2: ContentCache<Post2> = .init()
    
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

struct InstanceCacheGroup {
    var instance1: ContentCache<Instance1> = .init()
    var instance2: ContentCache<Instance2> = .init()
    var instance3: ContentCache<Instance3> = .init()
    
    func clean() {
        instance1.clean()
        instance2.clean()
        instance3.clean()
    }
}

struct WeakReference<Content: AnyObject> {
    weak var content: Content?
}

protocol CacheIdentifiable {
    var cacheId: Int { get }
}

class ContentCache<Content: ContentModel> {
    private var cachedItems: [Int: WeakReference<Content>] = .init()
    
    func createModel(api: ApiClient, for apiType: Content.ApiType) -> Content {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType)
            print("Using existing item for id \(apiType.cacheId)")
            return item
        }
        print("Creating new item for id \(apiType.cacheId)")
        let newItem = Content(source: api, from: apiType)
        cachedItems[apiType.cacheId] = .init(content: newItem)
        return newItem
    }
    
    /// Retrieves the cached model with the given cacheId, if present
    /// - Parameter cacheId: cacheId of the model to retrieve
    /// - Returns: cached model if present, nil otherwise
    func retrieveModel(cacheId: Int) -> Content? {
        cachedItems[cacheId]?.content
    }
    
    /// Remove dead references
    func clean() {
        for (key, value) in cachedItems where value.content == nil {
            print("Removed value with id \(key)")
            cachedItems[key] = nil
        }
    }
}

// class CoreContentCache<Content: CoreModel> {
//    private var cachedItems: [URL: WeakReference<Content>] = .init()
//
//    func retrieveModel(actorId: URL) -> Content? {
//        cachedItems[actorId]?.content
//    }
//
//    func createModel(for apiType: Content.ApiType) -> Content {
//        if let item = retrieveModel(actorId: apiType.actorId) {
//            print("Using existing item for id \(apiType.actorId)")
//            item.update(with: apiType)
//            return item
//        }
//        print("Creating new item for id \(apiType.actorId)")
//        let newItem = Content(from: apiType)
//        cachedItems[apiType.actorId] = .init(content: newItem)
//        return newItem
//    }
//
//    /// Remove dead references
//    func clean() {
//        for (key, value) in cachedItems where value.content == nil {
//            print("Removed value with id \(key)")
//            cachedItems[key] = nil
//        }
//    }
// }
//
// class BaseContentCache<Content: ContentModel & AnyObject> {
//    private var cachedItems: [Content.ID: WeakReference<Content>] = .init()
//
//    func retrieveModel(id: Content.ApiType.ID) -> Content? {
//        cachedItems[id]?.content
//    }
//
//    func createModel(source: ApiClient, for apiType: Content.ApiType) -> Content {
//        if let item = retrieveModel(id: apiType.id) {
//            item.update(with: apiType)
//            print("Using existing item for id \(apiType.id)")
//            return item
//        }
//        print("Creating new item for id \(apiType.id)")
//        let newItem = Content(source: source, from: apiType)
//        cachedItems[apiType.id] = .init(content: newItem)
//        return newItem
//    }
//
//    /// Remove dead references
//    func clean() {
//        for (key, value) in cachedItems where value.content == nil {
//            print("Removed value with id \(key)")
//            cachedItems[key] = nil
//        }
//    }
// }
