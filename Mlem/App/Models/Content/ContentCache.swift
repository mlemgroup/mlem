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
    var instanceStub: CoreCache<InstanceStub> = .init()
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

protocol CacheIdentifiable: AnyObject {
    var cacheId: Int { get }
}

/// Cache for content models
class ContentCache<Content: ContentModel>: CoreCache<Content> {
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
}

/// Cache for instance stub--exception case because there's no ApiType and it may need to perform ApiClient bootstrapping
class InstanceStubCache: CoreCache<InstanceStub> {
    func createModel(api: ApiClient, for url: URL) {
        let cacheId: Int = {
            var hasher: Hasher = .init()
            hasher.combine(url)
            return hasher.finalize()
        }()
        
        if let item = retrieveModel(cacheId: cacheId) {}
    }
}

/// Class providing common caching behavior
class CoreCache<Content: CacheIdentifiable> {
    var cachedItems: [Int: WeakReference<Content>] = .init()
    
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
