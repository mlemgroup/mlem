//
//  File.swift
//
//
//  Created by Sjmarf on 26/08/2024.
//

import Foundation

class ImageUpload1Cache: CoreCache<ImageUpload1> {
    func getModel(api: ApiClient, from snapshot: ImageUpload1Snapshot, semaphore: UInt? = nil) -> ImageUpload1 {
        if let item = retrieveModel(cacheId: snapshot.cacheId) { return item }
        
        let newItem: ImageUpload1 = .init(
            api: api,
            url: snapshot.url,
            alias: snapshot.alias,
            deleteToken: snapshot.deleteToken
        )

        itemCache.put(newItem)
        return newItem
    }
}
