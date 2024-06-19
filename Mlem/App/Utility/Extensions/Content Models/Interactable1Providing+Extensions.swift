//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import MlemMiddleware
import SwiftUI

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? { self as? any Interactable2Providing }
        
    // MARK: Counters
    
    var upvoteCounter: Counter {
        .init(
            value: self2?.votes.upvotes,
            leadingAction: upvoteAction,
            trailingAction: nil
        )
    }
    
    var downvoteCounter: Counter {
        .init(
            value: self2?.votes.downvotes,
            leadingAction: downvoteAction,
            trailingAction: nil
        )
    }
    
    var scoreCounter: Counter {
        .init(
            value: self2?.votes.total,
            leadingAction: upvoteAction,
            trailingAction: downvoteAction
        )
    }
    
    // MARK: Actions
    
    var upvoteAction: BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .upvote)
        return .init(
            id: "upvote\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Undo Upvote" : "Upvote",
            color: Palette.main.upvote,
            icon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill,
            callback: api.willSendToken ? self2?.toggleUpvote : nil
        )
    }
    
    var downvoteAction: BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .downvote)
        return .init(
            id: "downvote\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Undo Downvote" : "Downvote",
            color: Palette.main.downvote,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill,
            callback: api.willSendToken ? self2?.toggleDownvote : nil
        )
    }

    var saveAction: BasicAction {
        let isOn: Bool = self2?.saved ?? false
        return .init(
            id: "save\(actorId.absoluteString)",
            isOn: isOn,
            label: isOn ? "Unsave" : "Save",
            color: Palette.main.save,
            icon: isOn ? Icons.saveFill : Icons.save,
            menuIcon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill,
            callback: api.willSendToken ? self2?.toggleSave : nil
        )
    }
    
    // MARK: Readouts
    
    var createdReadout: Readout {
        .init(
            id: "created\(actorId)",
            label: (updated ?? created).getShortRelativeTime(),
            icon: updated == nil ? Icons.time : Icons.updated
        )
    }
    
    var scoreReadout: Readout {
        let icon: String
        let color: Color?
        switch self2?.votes.myVote {
        case .upvote:
            icon = Icons.upvoteSquareFill
            color = Palette.main.upvote
        case .downvote:
            icon = Icons.downvoteSquareFill
            color = Palette.main.downvote
        default:
            icon = Icons.upvoteSquare
            color = nil
        }
        return Readout(
            id: "score\(actorId)",
            label: self2?.votes.total.description,
            icon: icon,
            color: color
        )
    }
    
    var upvoteReadout: Readout {
        let isOn = self2?.votes.myVote == .upvote
        return Readout(
            id: "upvote\(actorId)",
            label: self2?.votes.upvotes.description,
            icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            color: isOn ? Palette.main.upvote : nil
        )
    }
    
    var downvoteReadout: Readout {
        let isOn = self2?.votes.myVote == .downvote
        return Readout(
            id: "downvote\(actorId)",
            label: self2?.votes.downvotes.description,
            icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            color: isOn ? Palette.main.downvote : nil
        )
    }
}
