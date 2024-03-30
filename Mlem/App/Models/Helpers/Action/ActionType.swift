//
//  ActionType.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

enum ActionType: String {
    case upvote, downvote, save
    
    static func upvoteAction(isOn: Bool) -> BasicAction {
        .init(
            type: .upvote,
            isOn: isOn,
            label: isOn ? "Undo Upvote" : "Upvote",
            color: Colors.upvoteColor,
            barIcon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill
        )
    }
    
    static func downvoteAction(isOn: Bool) -> BasicAction {
        .init(
            type: .downvote,
            isOn: isOn,
            label: isOn ? "Undo Downvote" : "Downvote",
            color: Colors.downvoteColor,
            barIcon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill
        )
    }
    
    static func saveAction(isOn: Bool) -> BasicAction {
        .init(
            type: .save,
            isOn: isOn,
            label: isOn ? "Undo Save": "Save",
            color: Colors.saveColor,
            barIcon: isOn ? Icons.saveFill : Icons.save,
            menuIcon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill
        )
    }
}
