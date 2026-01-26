//
//  PostPoll.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-26.
//

import Foundation

public struct PostPoll: Hashable {
    let endDate: Date?
    let localOnly: Bool?
    let latestVote: Date?

    let choices: [PostPollChoice]
}

public struct PostPollChoice: Hashable {
    let id: Int
    let label: String
    let voteCount: Int?
}

