//
//  NewApiClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension ApiClient {
    func getSite() async throws -> ApiGetSiteResponse {
        let request = GetSiteRequest()
        return try await perform(request: request)
    }
}
