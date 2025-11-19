//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-13.
//  

import Foundation

public struct LemmyCommunityBlockBridge: Codable, Hashable, Sendable {
    public let community: LemmyCommunity
    
    public init(from decoder: any Decoder) throws {
        if let community = try? LemmyCommunity(from: decoder) {
            self.community = community
            return
        }
        let view = try LemmyCommunityBlockView(from: decoder)
        self.community = view.community
    }
}

public struct LemmyPersonBlockBridge: Codable, Hashable, Sendable {
    public let person: LemmyPerson
    
    public init(from decoder: any Decoder) throws {
        if let person = try? LemmyPerson(from: decoder) {
            self.person = person
            return
        }
        let view = try LemmyPersonBlockView(from: decoder)
        self.person = view.target
    }
}
