//
//  PieFedFallbackGetVersionRequest.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-05.
//

import Rest

public struct PieFedFallbackGetVersionRequest: GetRequest {
    public typealias Parameters = Int

    public struct Response: Decodable {
        let version: SiteVersion
    }
    
    public let path: String = "api/alpha/site"
    public let parameters: Parameters? = nil
}
