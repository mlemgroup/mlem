//
//  ContentCache.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

struct DependentContentCacheGroup {
    var community1: DependentContentCache<CommunityTier1> = .init()
    var community2: DependentContentCache<CommunityTier2> = .init()
    var community3: DependentContentCache<CommunityTier3> = .init()
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

class IndepenentContentCache<Content: IndependentContentModel> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func createModel(for apiType: Content.APIType) -> Content {
        if let item = cachedItems.first(where: { $0.content?.id == apiType.id }) {
            print("Using existing item for id \(apiType.id)")
            return item.content!
        }
        print("Creating new item for id \(apiType.id)")
        let newItem = Content(from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}

class DependentContentCache<Content: DependentContentModel & AnyObject> {
    private var cachedItems: [WeakReference<Content>] = .init()
    
    func createModel(source: any APISource, for apiType: Content.APIType) -> Content {
        if let item = cachedItems.first(where: { $0.content?.id == apiType.id }) {
            print("Using existing item for id \(apiType.id)")
            return item.content!
        }
        print("Creating new item for id \(apiType.id)")
        let newItem = Content(source: source, from: apiType)
        cachedItems.append(.init(content: newItem))
        return newItem
    }
}
