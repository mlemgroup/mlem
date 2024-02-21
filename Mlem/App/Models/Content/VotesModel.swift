//
//  VotesModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-26.
//

import Foundation

struct VotesModel: Hashable {
    var total: Int { upvotes - downvotes }
    var upvotes: Int
    var downvotes: Int
    var myVote: ScoringOperation

    // init from API type
    init(from voteCount: any ApiContentAggregatesProtocol, myVote: ScoringOperation?) {
        self.upvotes = voteCount.upvotes
        self.downvotes = voteCount.downvotes
        self.myVote = myVote ?? .none
    }

    // raw init
    init(upvotes: Int, downvotes: Int, myVote: ScoringOperation) {
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.myVote = myVote
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(upvotes)
        hasher.combine(downvotes)
        hasher.combine(myVote)
    }
}

extension VotesModel {
    /// Returns the result of applying the given scoring operation. Assumes that it is a valid operation (i.e., not upvoting an upvoted post or downvoting a downvoted one)
    /// - Parameter operation: operation to apply
    /// - Returns: VotesModel representing the result of applying the given operation
    func applyScoringOperation(operation: ScoringOperation) -> VotesModel {
        assert(!(operation == .upvote && myVote == .upvote), "Cannot apply upvote to upvoted score")
        assert(!(operation == .downvote && myVote == .downvote), "Cannot apply downvote to downvoted score")

        var upvoteDelta: Int
        var downvoteDelta: Int

        switch myVote {
        case .upvote:
            // no matter what, removing 1 upvote; if downvoting, adding 1 downvote
            upvoteDelta = -1
            downvoteDelta = operation == .downvote ? 1 : 0
        case .none:
            // adding 1 to whichever operation we get as long as it's not resetVote
            upvoteDelta = operation == .upvote ? 1 : 0
            downvoteDelta = operation == .downvote ? 1 : 0
        case .downvote:
            // no matter what, removing 1 downvote; if upvoting, adding 1 upvote
            upvoteDelta = operation == .upvote ? 1 : 0
            downvoteDelta = -1
        }

        return VotesModel(
            upvotes: upvotes + upvoteDelta,
            downvotes: downvotes + downvoteDelta,
            myVote: operation
        )
    }
}
