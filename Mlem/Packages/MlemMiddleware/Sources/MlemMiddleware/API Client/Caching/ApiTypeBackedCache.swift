//
//  ContentCache.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

/// Class providing caching behavior for models associated with API types
class ApiTypeBackedCache<Content: CacheIdentifiable & AnyObject & ContentModel, ApiType: CacheIdentifiable>: CoreCache<Content> {
    @MainActor func getModel(
        api: ApiClient,
        from apiType: ApiType,
        // If `true`, the model will not be updated with the incoming data if the model already exists.
        isStale: Bool = false
    ) -> Content {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            if !isStale {
                updateModel(item, with: apiType)
            }
            return item
        }
        
        let newItem: Content = performModelTranslation(api: api, from: apiType)
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: any Sequence<ApiType>,
        isStale: Bool = false
    ) -> [Content] {
        apiTypes.map { getModel(api: api, from: $0, isStale: isStale) }
    }
    
    @MainActor
    func getOptionalModel(
        api: ApiClient,
        from apiType: ApiType?,
        isStale: Bool = false
    ) -> Content? {
        if let apiType {
            return getModel(api: api, from: apiType, isStale: isStale)
        }
        return nil
    }
    
    /// Initializes a new middleware model from the associated API type
    /// - Warning: This method DOES NOT CACHE! You almost certainly want to be using `getModel` instead.
    @MainActor
    func performModelTranslation(api: ApiClient, from apiType: ApiType) -> Content {
        // the name of this method is intentionally unwieldy to further discourage accidental use
        preconditionFailure("This method must be overridden by the instantiating class: \(self)")
    }
    
    @MainActor
    func updateModel(_ item: Content, with apiType: ApiType) {
        preconditionFailure("This method must be overridden by the instantiating class: \(self)")
    }
}
