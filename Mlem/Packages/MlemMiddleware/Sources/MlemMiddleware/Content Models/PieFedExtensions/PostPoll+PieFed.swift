//
//  PostPoll+PieFed.swift
//  Mlem
//
//  Created by Sjmarf on 2026-01-26.
//

extension PostPoll {
    init(from poll: PieFedPostPoll) {
        self.endDate = poll.endPoll
        self.latestVote = poll.latestVote
        self.localOnly = poll.localOnly
        self.choices = poll.choices.map { .init(from: $0) }
    }
}

extension PostPollChoice {
    init(from choice: PieFedPollChoice) {
        self.id = choice.id
        self.label = choice.choiceText
        self.voteCount = choice.numVotes
    }
}
