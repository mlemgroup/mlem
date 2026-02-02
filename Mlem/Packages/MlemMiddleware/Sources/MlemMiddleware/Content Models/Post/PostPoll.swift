//
//  PostPoll.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-26.
//

import Foundation

public struct PostPoll: Hashable {
    public let endDate: Date?
    public let localOnly: Bool?
    public let latestVote: Date?

    public let choices: [PostPollChoice]

    public var hasEnded: Bool {
        if let endDate {
            endDate < .now
        } else {
            false
        }
    }

    public var totalVotes: Int {
        choices.compactMap(\.voteCount).reduce(0, +)
    }

    public var hasVoted: Bool {
        choices.contains { $0.selected }
    }
}

public struct PostPollChoice: Hashable {
    public let id: Int
    public let label: String
    public let voteCount: Int?
    public var selected: Bool

    public func percentage(poll: PostPoll) -> Int {
        if poll.totalVotes == 0 {
            0
        } else {
            Int(100 * Double(voteCount ?? 0) / Double(poll.totalVotes))
        }
    }
}

