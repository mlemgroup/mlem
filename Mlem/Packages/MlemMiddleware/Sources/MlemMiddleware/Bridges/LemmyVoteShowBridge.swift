//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-13.
//  

import Foundation

public struct LemmyVoteShowBridge: Codable, Hashable, Sendable {
    let voteShow: LemmyVoteShow
    
    public var boolValue: Bool {
        get throws {
            switch voteShow {
            case .show: true
            case .hide: false
            case .showForOthers: throw LemmyEncodingError.lemmyVoteShowBridge
            }
        }
    }
    
    public init(showVotes: Bool) {
        self.voteShow = showVotes ? .show : .hide
    }
    
    public init(from decoder: any Decoder) throws {
        if let vote = try? LemmyVoteShow(from: decoder) {
            voteShow = vote
        } else {
            let bool = try Bool(from: decoder)
            self.voteShow = bool ? .show : .hide
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        switch try encoder.endpointVersion {
        case .v3: try boolValue.encode(to: encoder)
        case .v4: try voteShow.encode(to: encoder)
        }
    }
}
