//
//  Interactable1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-02.
//

import Foundation
import MlemMiddleware

extension Interactable1Providing {
    private var self2: (any Interactable2Providing)? { self as? any Interactable2Providing }
        
    func toggleUpvoteWithHaptics() {
        if let self2 {
            HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            self2.toggleUpvote()
        } else {
            print("DEBUG no self2 found in toggleUpvoteWithHaptics!")
        }
    }
    
    func toggleDownvoteWithHaptics() {
        if let self2 {
            HapticManager.main.play(haptic: .lightSuccess, priority: .low)
            self2.toggleDownvote()
        } else {
            print("DEBUG no self2 found in toggleDownvoteWithHaptics!")
        }
    }
    
    func toggleSaveWithHaptics() {
        if let self2 {
            HapticManager.main.play(haptic: .success, priority: .low)
            self2.toggleSave()
        } else {
            print("DEBUG no self2 found in toggleSaveWithHaptics!")
        }
    }
    
    var upvoteAction: BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .upvote)
        return .init(
            isOn: isOn,
            label: isOn ? "Undo Upvote" : "Upvote",
            color: Palette.main.upvote,
            icon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill,
            callback: api.willSendToken ? toggleUpvoteWithHaptics : nil
        )
    }
    
    var downvoteAction: BasicAction {
        let isOn: Bool = (self2?.votes.myVote ?? .none == .downvote)
        return .init(
            isOn: isOn,
            label: isOn ? "Undo Downvote" : "Downvote",
            color: Palette.main.downvote,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill,
            callback: api.willSendToken ? self2?.toggleDownvoteWithHaptics : nil
        )
    }

    var saveAction: BasicAction {
        let isOn: Bool = self2?.saved ?? false
        return .init(
            isOn: isOn,
            label: isOn ? "Unsave" : "Save",
            color: Palette.main.save,
            icon: isOn ? Icons.saveFill : Icons.save,
            menuIcon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill,
            callback: api.willSendToken ? self2?.toggleSaveWithHaptics : nil
        )
    }
}
