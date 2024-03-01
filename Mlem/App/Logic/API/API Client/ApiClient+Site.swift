//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    static func bootstrapInstance(url: URL) -> InstanceStub {
        // compute cache id
        var hasher: Hasher = .init()
        hasher.combine(url)
        let cacheId = hasher.finalize()
        
        if let existing = ApiClient.instanceCaches.instanceStub.retrieveModel(cacheId: cacheId) {
            return existing
        }
        
        let newInstanceStub = .init
    }
    
    func getSite() async throws -> ApiGetSiteResponse {
        let request = GetSiteRequest()
        return try await perform(request)
    }
}
