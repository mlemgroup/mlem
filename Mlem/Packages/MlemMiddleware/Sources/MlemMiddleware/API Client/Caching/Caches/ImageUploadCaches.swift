//
//  File.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

class ImageUpload1Cache: CoreCache<ImageUpload1> {
    func getModel(api: ApiClient, from apiType: any ImageUpload1Backer, semaphore: UInt? = nil) -> ImageUpload1 {
        if let item = retrieveModel(cacheId: apiType.cacheId) { return item }
        
        let newItem: ImageUpload1 = .init(
            api: api,
            alias: apiType.alias,
            deleteToken: apiType.deleteToken
        )

        itemCache.put(newItem)
        return newItem
    }
}
