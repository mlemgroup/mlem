//
//  LemmyFallbackGetVersionRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-05.
//

import Rest

public struct LemmyFallbackGetVersionRequest: GetRequest {
    public typealias Parameters = Int

    public struct Response: Decodable {
        let version: SiteVersion
    }
    
    public let path: String
    public let parameters: Parameters? = nil
    
    init(
      endpoint: LemmyEndpointVersion
    ) {
        self.path = endpoint == .v4 ? "api/v4/site" : "api/v3/site"
    }
}
