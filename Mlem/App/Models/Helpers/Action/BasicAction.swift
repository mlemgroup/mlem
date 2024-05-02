//
//  BasicAction.swift
//  Mlem
//
//  Created by Sjmarf on 31/03/2024.
//

import SwiftUI

struct BasicAction: Action {
    let id: UUID = .init()
    let isOn: Bool
    
    let label: String
    let isDestructive: Bool
    let color: Color
    
    let barIcon: String
    let menuIcon: String
    let swipeIcon1: String
    let swipeIcon2: String
    
    /// If this is nil, the BasicAction is disabled
    var callback: (() -> Void)?
    
    init(
        isOn: Bool,
        label: String,
        color: Color,
        isDestructive: Bool = false,
        icon: String,
        barIcon: String? = nil,
        menuIcon: String? = nil,
        swipeIcon1: String? = nil,
        swipeIcon2: String? = nil,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.isOn = isOn
        self.label = label
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon ?? icon
        self.menuIcon = menuIcon ?? icon
        self.swipeIcon1 = swipeIcon1 ?? icon
        self.swipeIcon2 = swipeIcon2 ?? icon
        self.callback = enabled ? callback : nil
    }
    
    static func upvote(isOn: Bool, callback: (() -> Void)? = nil) -> BasicAction {
        .init(
            isOn: isOn,
            label: isOn ? "Undo Upvote" : "Upvote",
            color: Colors.upvoteColor,
            icon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill,
            callback: callback
        )
    }
    
    static func downvote(isOn: Bool, callback: (() -> Void)? = nil) -> BasicAction {
        .init(
            isOn: isOn,
            label: isOn ? "Undo Downvote" : "Downvote",
            color: Colors.downvoteColor,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill,
            callback: callback
        )
    }
    
    static func save(isOn: Bool, callback: (() -> Void)? = nil) -> BasicAction {
        .init(
            isOn: isOn,
            label: isOn ? "Unsave" : "Save",
            color: Colors.saveColor,
            icon: isOn ? Icons.saveFill : Icons.save,
            menuIcon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill,
            callback: callback
        )
    }
}
