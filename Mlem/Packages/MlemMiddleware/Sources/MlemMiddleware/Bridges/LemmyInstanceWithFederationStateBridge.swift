//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-21.
//

import Foundation

public struct LemmyInstanceWithFederationStateBridge: Codable, Hashable, Sendable {
    let domain: String
    
    public init(from decoder: any Decoder) throws {
        if let old = try? LemmyInstance(from: decoder) {
            self.domain = old.domain
            return
        }
        
        if let new = try? LemmyInstanceWithFederationState(from: decoder) {
            self.domain = new.domain
            return
        }
        
        throw DecodingError.dataCorrupted(
            .init(codingPath: decoder.codingPath, debugDescription: "LemmyInstanceWithFederationStateBridge error")
        )
    }
}
