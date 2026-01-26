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
}

public struct PostPollChoice: Hashable {
    public let id: Int
    public let label: String
    public let voteCount: Int?
}

