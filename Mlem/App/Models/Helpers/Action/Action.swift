//
//  Action.swift
//  Mlem
//
//  Created by Sjmarf on 30/03/2024.
//

import SwiftUI

protocol Action: Identifiable {
    var id: UUID { get }
    
    var type: ActionType { get }
    var isOn: Bool { get }
    
    var label: String { get }
    var isDestructive: Bool { get }
    var color: Color { get }
    
    var barIcon: String { get }
    var menuIcon: String { get }
    var swipeIcon1: String { get }
    var swipeIcon2: String { get }
}

struct BasicAction: Action {
    let id: UUID = .init()
    
    let type: ActionType
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
        type: ActionType,
        isOn: Bool,
        label: String,
        color: Color,
        isDestructive: Bool = false,
        barIcon: String,
        menuIcon: String,
        swipeIcon1: String,
        swipeIcon2: String,
        enabled: Bool = true,
        callback: (() -> Void)? = nil
    ) {
        self.type = type
        self.isOn = isOn
        self.label = label
        self.isDestructive = isDestructive
        self.color = color
        self.barIcon = barIcon
        self.menuIcon = menuIcon
        self.swipeIcon1 = swipeIcon1
        self.swipeIcon2 = swipeIcon2
        self.callback = enabled ? callback : nil
    }
    
    static func upvote(isOn: Bool) -> BasicAction {
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
    
    static func downvote(isOn: Bool) -> BasicAction {
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
    
    static func save(isOn: Bool) -> BasicAction {
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
