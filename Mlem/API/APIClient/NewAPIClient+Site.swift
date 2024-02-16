//
//  NewAPIClient+Site.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

extension NewAPIClient {
    func getSite() async throws -> SiteResponse {
        let request = GetSiteRequest()
        return try await perform(request: request)
    }
}
