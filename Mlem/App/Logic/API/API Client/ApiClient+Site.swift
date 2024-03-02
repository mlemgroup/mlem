//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    func getSite() async throws -> Instance3 {
        let request = GetSiteRequest()
        let response = try await perform(request)
        
        return caches.instance3.getModel(api: self, from: response)
    }
}
