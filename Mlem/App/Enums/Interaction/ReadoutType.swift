//
//  ReadoutType.swift
//  Mlem
//
//  Created by Sjmarf on 2026-07-19.
//

import Foundation

enum ReadoutType: String, Codable, CaseIterable, Hashable {
    case created
    case score
    case upvote
    case downvote
    case comment
    case saved
        
    var appearance: MockReadoutAppearance {
        switch self {
        case .created: .init(icon: .general.time, label: "18h")
        case .score: .init(icon: .lemmy.votes, label: "7")
        case .upvote: .init(icon: .lemmy.upvoted, label: "9")
        case .downvote: .init(icon: .lemmy.downvoted, label: "2")
        case .comment: .init(icon: .lemmy.replies, label: "1")
        case .saved: .init(icon: .lemmy.saved, label: "")
        }
    }
        
    func compatibleWith(otherReadouts: Set<Self>) -> Bool {
        switch self {
        case .score: otherReadouts.isDisjoint(with: [.upvote, .downvote])
        case .upvote, .downvote: !otherReadouts.contains(.score)
        default: true
        }
    }
}
