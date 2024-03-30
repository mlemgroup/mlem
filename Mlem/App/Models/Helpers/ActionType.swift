//
//  ActionType.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

// Cases for *all* model types need to go in here if we want to avoid having duplicate logic for posts/comments. I'd have preferred to have separate ActionType enums for each content type if possible, but alas I think the cons of doing that outweight the pros - sjmarf

enum ActionType: String {
    case upvote, downvote, save
    
    func label(_ isOn: Bool) -> String {
        switch self {
        case .upvote:
            isOn ? "Undo Upvote" : "Upvote"
        case .downvote:
            isOn ? "Undo Downvote": "Downvote"
        case .save:
            isOn ? "Undo Save": "Save"
        }
    }
    
    var color: Color {
        switch self {
        case .upvote:
            Colors.upvoteColor
        case .downvote:
            Colors.downvoteColor
        case .save:
            Colors.saveColor
        }
    }
    
    // MARK: - Icons
    
    func barIcon(isOn: Bool) -> String {
        switch self {
        case .upvote:
            Icons.upvote
        case .downvote:
            Icons.downvote
        case .save:
            isOn ? Icons.saveFill : Icons.save
        }
    }
    
    func menuIcon(isOn: Bool) -> String {
        switch self {
        case .upvote:
            isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare
        case .downvote:
            isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare
        case .save:
            isOn ? Icons.saveFill : Icons.save
        }
    }
    
    func swipeIcon1(isOn: Bool) -> String {
        switch self {
        case .upvote:
            isOn ? Icons.resetVoteSquare : Icons.upvoteSquare
        case .downvote:
            isOn ? Icons.resetVoteSquare : Icons.downvoteSquare
        case .save:
            isOn ? Icons.unsave : Icons.save
        }
    }
    
    func swipeIcon2(isOn: Bool) -> String {
        switch self {
        case .upvote:
            isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill
        case .downvote:
            isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill
        case .save:
            isOn ? Icons.unsaveFill : Icons.saveFill
        }
    }
}
