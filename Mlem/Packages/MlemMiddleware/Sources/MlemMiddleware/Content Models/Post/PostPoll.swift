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

    public var choices: [PostPollChoice]

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

    func applyVoteChoices(choiceIds: Set<Int>) -> PostPoll {
        var new = self
        new.choices = []
        for choice in self.choices {
            var choice = choice
            let newSelected = choiceIds.contains(choice.id)
            if choice.selected {
                choice.voteCount = (choice.voteCount ?? 0) - 1
            }
            if newSelected {
                choice.voteCount = (choice.voteCount ?? 0) + 1
            }
            choice.selected = newSelected
            new.choices.append(choice)
        }
        return new
    }
}

public struct PostPollChoice: Hashable {
    public let id: Int
    public let label: String
    public var voteCount: Int?
    public var selected: Bool

    public func percentage(poll: PostPoll) -> Int {
        if poll.totalVotes == 0 {
            0
        } else {
            Int(100 * Double(voteCount ?? 0) / Double(poll.totalVotes))
        }
    }
}

