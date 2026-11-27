//
//  VotesModel+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-17.
//

import Icons
import MlemMiddleware
import Theming

extension VotesModel {
    var icon: Icon { myVote.icon }
    var color: ThemedColor { myVote.color }

    /// Percentage of votes that are upvotes, rounded to the nearest whole number. `nil` when there are no votes.
    var upvotePercentage: Int? {
        let totalVotes = upvotes + downvotes
        guard totalVotes > 0 else { return nil }
        return Int((Double(upvotes) / Double(totalVotes) * 100).rounded())
    }
}
