//
//  Interactable1Providing+Actions.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import Foundation

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? {
        self as? any Interactable2Providing
    }
    
    var upvoteAction: Action {
        if self2?.votes.myVote == .upvote {
            return .init(
                label: "Undo Upvote",
                barIsOn: true,
                barIcon: Icons.upvote,
                menuIcon: Icons.upvoteSquareFill,
                swipeIcon: Icons.resetVoteSquare,
                swipeIcon2: Icons.resetVoteSquareFill,
                color: Colors.upvoteColor
            ) {
                self.self2?.vote(.none)
            }
        } else {
            return .init(
                label: "Upvote",
                enabled: self2 != nil,
                barIcon: Icons.upvote,
                menuIcon: Icons.upvoteSquare,
                swipeIcon: Icons.upvoteSquare,
                swipeIcon2: Icons.upvoteSquareFill,
                color: Colors.upvoteColor
            ) {
                self.self2?.vote(.upvote)
            }
        }
    }
    
    var downvoteAction: Action {
        if self2?.votes.myVote == .downvote {
            return .init(
                label: "Undo Downvote",
                barIsOn: true,
                barIcon: Icons.downvote,
                menuIcon: Icons.downvoteSquareFill,
                swipeIcon: Icons.resetVoteSquare,
                swipeIcon2: Icons.resetVoteSquareFill,
                color: Colors.downvoteColor
            ) {
                self.self2?.vote(.none)
            }
        } else {
            return .init(
                label: "Downvote",
                enabled: self2 != nil,
                barIcon: Icons.downvote,
                menuIcon: Icons.downvoteSquare,
                swipeIcon: Icons.downvoteSquare,
                swipeIcon2: Icons.downvoteSquareFill,
                color: Colors.downvoteColor
            ) {
                self.self2?.vote(.downvote)
            }
        }
    }
}
