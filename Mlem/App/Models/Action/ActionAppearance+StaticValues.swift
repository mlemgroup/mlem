//
//  ActionAppearance+StaticValues.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import Foundation

extension ActionAppearance {
    static func upvote(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Undo Upvote" : "Upvote",
            isOn: isOn,
            color: Palette.main.upvote,
            icon: Icons.upvote,
            menuIcon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.upvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.upvoteSquareFill
        )
    }
    
    static func downvote(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Undo Downvote" : "Downvote",
            isOn: isOn,
            color: Palette.main.downvote,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill
        )
    }
    
    static func save(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Unsave" : "Save",
            color: Palette.main.save,
            icon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill
        )
    }
    
    static func reply() -> Self {
        .init(
            label: "Reply",
            color: Palette.main.accent,
            icon: Icons.reply,
            swipeIcon2: Icons.replyFill
        )
    }
    
    static func blockCreator() -> Self {
        .init(
            label: "Block User",
            isOn: false,
            isDestructive: true,
            color: Palette.main.negative,
            icon: Icons.block
        )
    }
    
    static func block(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Unblock" : "Block",
            isOn: isOn,
            isDestructive: !isOn,
            color: Palette.main.negative,
            icon: isOn ? Icons.show : Icons.hide
        )
    }
    
    static func hide(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Show" : "Hide",
            isOn: isOn,
            color: .gray,
            icon: isOn ? Icons.show : Icons.hide
        )
    }
    
    static func selectText() -> Self {
        .init(
            label: "Select Text",
            isOn: false,
            color: Palette.main.accent,
            icon: Icons.select
        )
    }
    
    static func share() -> Self {
        .init(
            label: "Share...",
            color: .gray,
            icon: Icons.share
        )
    }
}
