//
//  CounterType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-19.
//

import Foundation
import MlemMiddleware
    
enum CounterType: String, Codable, CaseIterable, Hashable {
    case score
    case upvote
    case downvote
    case reply
        
    static var defaultWidgets: [CounterType] { allCases }
        
    var appearance: CounterAppearance {
        switch self {
        case .score: .score()
        case .upvote: .upvote()
        case .downvote: .downvote()
        case .reply: .reply()
        }
    }
        
    func associatedReadouts(context: any InteractableProviding) -> Set<ReadoutType> {
        switch self {
        case .score: [.upvote, .downvote, .score]
        case .upvote: context.votes.value?.myVote ?? .none == .upvote ? [.upvote, .score] : [.upvote]
        case .downvote: context.votes.value?.myVote ?? .none == .downvote ? [.downvote, .score] : [.downvote]
        case .reply: []
        }
    }
}
