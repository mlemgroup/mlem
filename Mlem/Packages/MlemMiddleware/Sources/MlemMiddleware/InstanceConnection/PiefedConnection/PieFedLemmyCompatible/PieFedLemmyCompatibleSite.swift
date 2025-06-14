//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation
import Rest

// These schemas are defined by hand and only include the necessary data - parts are omitted.
// In theory we could squeeze more data out of this by adding some of the other properties,
// but I'd rather just wait for PieFed to implement actual support for those

public struct PieFedLemmyCompatibleGetSiteRequest: GetRequest {
    public typealias Parameters = Int
    public typealias Response = PieFedLemmyCompatibleSiteResponse
    
    public let path: String
    public let parameters: Parameters? = nil
    
    init() {
        self.path = "api/v3/site"
    }
}

public struct PieFedLemmyCompatibleSiteResponse: Codable, Hashable, Sendable {
    public let siteView: PieFedLemmyCompatibleSiteView
}

public extension PieFedLemmyCompatibleSiteResponse {
    enum CodingKeys: String, CodingKey {
        case siteView = "site_view"
    }
}

public struct PieFedLemmyCompatibleSiteView: Codable, Hashable, Sendable {
    public let counts: ApiSiteAggregates
}

public extension PieFedLemmyCompatibleSiteView {
    enum CodingKeys: String, CodingKey {
        case counts
    }
}
