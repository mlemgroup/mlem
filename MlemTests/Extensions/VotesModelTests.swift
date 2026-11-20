//
//  VotesModelTests.swift
//  Mlem
//

import Foundation
import MlemMiddleware
import Testing
@testable import Mlem

struct VotesModelTests {
    @Test func upvotePercentageWithNoVotesIsNil() {
        let votes = VotesModel(upvotes: 0, downvotes: 0, myVote: .none)
        #expect(votes.upvotePercentage == nil)
    }

    @Test func upvotePercentageWithOnlyUpvotesIsHundred() {
        let votes = VotesModel(upvotes: 7, downvotes: 0, myVote: .none)
        #expect(votes.upvotePercentage == 100)
    }

    @Test func upvotePercentageWithOnlyDownvotesIsZero() {
        let votes = VotesModel(upvotes: 0, downvotes: 3, myVote: .none)
        #expect(votes.upvotePercentage == 0)
    }

    @Test func upvotePercentageRoundsToNearestWholeNumber() {
        // 2 / 3 = 66.67% -> 67
        let votes = VotesModel(upvotes: 2, downvotes: 1, myVote: .none)
        #expect(votes.upvotePercentage == 67)
    }

    @Test func upvotePercentageIsNotAffectedByMyVote() {
        let votes = VotesModel(upvotes: 3, downvotes: 1, myVote: .downvote)
        #expect(votes.upvotePercentage == 75)
    }
}
