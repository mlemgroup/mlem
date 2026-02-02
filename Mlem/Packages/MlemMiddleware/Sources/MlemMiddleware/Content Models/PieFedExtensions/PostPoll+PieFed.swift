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
        let myVotes = poll.myVotes ?? []
        self.choices = poll.choices.map { .init(from: $0, selected: myVotes.contains($0.id)) }
    }
}

extension PostPollChoice {
    init(from choice: PieFedPollChoice, selected: Bool) {
        self.id = choice.id
        self.label = choice.choiceText
        self.voteCount = choice.numVotes
        self.selected = selected
    }
}
