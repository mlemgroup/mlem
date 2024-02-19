//
//  NewAPIClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension APIClient {
    func getSite() async throws -> APIGetSiteResponse {
        let request = GetSiteRequest()
        return try await perform(request: request)
    }
}
