//
//  ContentCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

/// Class providing caching behavior for models associated with API types
class ApiTypeBackedCache<Content: ContentModel, ApiType: CacheIdentifiable>: CoreCache<Content> {
    func getModel(api: ApiClient, from apiType: ApiType) -> Content {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            updateModel(item, with: apiType)
            return item
        }
        
        let newItem: Content = createModel(api: api, from: apiType)
        cachedItems[newItem.cacheId] = .init(content: newItem)
        return newItem
    }
    
    /// Initializes a new middleware model from the associated API type
    /// - Warning: This method DOES NOT CACHE! You almost certainly want to be using `getModel` instead.
    func createModel(api: ApiClient, from apiType: ApiType) -> Content {
        preconditionFailure("This method must be overridden by the instantiating class")
    }
    
    func updateModel(_ item: Content, with apiType: ApiType) {
        preconditionFailure("This method must be overridden by the instantiating class")
    }
}
