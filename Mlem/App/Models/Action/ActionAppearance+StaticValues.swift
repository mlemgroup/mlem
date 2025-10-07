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
            color: .themedUpvote,
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
            color: .themedDownvote,
            icon: Icons.downvote,
            menuIcon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
            swipeIcon1: isOn ? Icons.resetVoteSquare : Icons.downvoteSquare,
            swipeIcon2: isOn ? Icons.resetVoteSquareFill : Icons.downvoteSquareFill
        )
    }
    
    static func save(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Unsave" : "Save",
            isOn: isOn,
            color: .themedSave,
            icon: isOn ? Icons.saveFill : Icons.save,
            swipeIcon1: isOn ? Icons.unsave : Icons.save,
            swipeIcon2: isOn ? Icons.unsaveFill : Icons.saveFill
        )
    }
    
    static func reply() -> Self {
        .init(
            label: "Reply",
            color: .themedAccent,
            icon: Icons.reply,
            swipeIcon2: Icons.replyFill
        )
    }
    
    static func blockCreator() -> Self {
        .init(
            label: "Block User",
            isOn: false,
            isDestructive: true,
            color: .themedNegative,
            icon: Icons.block,
            swipeIcon2: Icons.blockFill
        )
    }
    
    static func banFromInstance(isOn: Bool, withUserLabel: Bool = false) -> Self {
        .init(
            label: getBanLabel(isOn: isOn, withUserLabel: withUserLabel),
            isOn: isOn,
            isDestructive: !isOn,
            color: isOn ? .themedPositive : .themedNegative,
            icon: isOn ? Icons.unbanFromInstance : Icons.banFromInstance,
            swipeIcon2: isOn ? Icons.unbanFromInstanceFill : Icons.banFromInstanceFill
        )
    }
    
    static func banFromCommunity(isOn: Bool, withUserLabel: Bool = false) -> Self {
        .init(
            label: getBanLabel(isOn: isOn, withUserLabel: withUserLabel),
            isOn: isOn,
            isDestructive: !isOn,
            color: isOn ? .themedPositive : .themedNegative,
            icon: isOn ? Icons.unbanFromCommunity : Icons.banFromCommunity,
            swipeIcon2: isOn ? Icons.unbanFromCommunityFill : Icons.banFromCommunityFill
        )
    }
    
    private static func getBanLabel(isOn: Bool, withUserLabel: Bool) -> LocalizedStringResource {
        if withUserLabel {
            isOn ? "Unban User" : "Ban User"
        } else {
            isOn ? "Unban" : "Ban"
        }
    }
    
    static func block(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Unblock" : "Block",
            isOn: isOn,
            isDestructive: !isOn,
            color: .themedNegative,
            icon: isOn ? Icons.unblock : Icons.block,
            swipeIcon2: isOn ? Icons.unblockFill : Icons.blockFill
        )
    }
    
    static func hide(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Show" : "Hide",
            isOn: isOn,
            color: .themedNeutralAccent,
            icon: isOn ? Icons.show : Icons.hide
        )
    }
    
    static func selectText() -> Self {
        .init(
            label: "Select Text",
            isOn: false,
            color: .themedAccent,
            icon: Icons.select
        )
    }
    
    static func share() -> Self {
        .init(
            label: "Share...",
            color: .themedNeutralAccent,
            icon: Icons.share
        )
    }
    
    static func report() -> Self {
        .init(
            label: "Report",
            isOn: false,
            isDestructive: true,
            color: .themedNegative,
            icon: Icons.moderationReport,
            swipeIcon2: Icons.moderationReportFill
        )
    }
    
    static func markRead(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Mark Unread" : "Mark Read",
            isOn: isOn,
            color: .themedRead,
            icon: isOn ? Icons.markUnread : Icons.markRead,
            swipeIcon1: isOn ? Icons.markRead : Icons.markUnread,
            swipeIcon2: isOn ? Icons.markUnreadFill : Icons.markReadFill
        )
    }
    
    static func edit() -> Self {
        .init(label: "Edit", color: .themedAccent, icon: Icons.edit)
    }
    
    static func pin(isOn: Bool, isInProgress: Bool = false) -> Self {
        .init(
            label: isOn ? "Unpin" : "Pin",
            isOn: isOn,
            isInProgress: isInProgress,
            color: .themedModeration,
            icon: isOn ? Icons.unpin : Icons.pin,
            barIcon: isOn ? Icons.pinFill : Icons.pin,
            swipeIcon2: isOn ? Icons.unpinFill : Icons.pinFill
        )
    }
    
    static func pinToCommunity(isOn: Bool, isInProgress: Bool = false) -> Self {
        .init(
            label: isOn ? "Unpin From Community" : "Pin to Community",
            isOn: isOn,
            isInProgress: isInProgress,
            color: .themedModeration,
            icon: isOn ? Icons.unpin : Icons.pin,
            barIcon: isOn ? Icons.pinFill : Icons.pin,
            swipeIcon2: isOn ? Icons.unpinFill : Icons.pinFill
        )
    }
    
    static func pinToInstance(isOn: Bool, isInProgress: Bool = false) -> Self {
        .init(
            label: isOn ? "Unpin From Instance" : "Pin to Instance",
            isOn: isOn,
            isInProgress: isInProgress,
            color: .themedAdministration,
            icon: isOn ? Icons.unpin : Icons.pin,
            barIcon: isOn ? Icons.pinFill : Icons.pin,
            swipeIcon2: isOn ? Icons.unpinFill : Icons.pinFill
        )
    }
    
    static func lock(isOn: Bool, isInProgress: Bool = false) -> Self {
        .init(
            label: isOn ? "Unlock" : "Lock",
            isOn: isOn,
            isInProgress: isInProgress,
            color: .themedLockAccent,
            icon: isOn ? Icons.unlock : Icons.lock,
            barIcon: isOn ? Icons.lockFill : Icons.lock,
            swipeIcon2: isOn ? Icons.unlockFill : Icons.lockFill
        )
    }
    
    static func remove(isOn: Bool, isInProgress: Bool = false) -> Self {
        .init(
            label: isOn ? "Restore" : "Remove",
            isOn: false,
            isInProgress: isInProgress,
            isDestructive: !isOn,
            color: isOn ? .themedPositive : .themedNegative,
            icon: isOn ? Icons.restore : Icons.remove,
            swipeIcon2: isOn ? Icons.restoreFill : Icons.removeFill
        )
    }
    
    static func toggleNsfw(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Remove NSFW Tag" : "Add NSFW Tag",
            color: .themedNegative,
            icon: Icons.blurNsfw
        )
    }
    
    static func resolve(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Unresolve" : "Resolve",
            isOn: isOn,
            color: .themedPositive,
            icon: isOn ? Icons.unresolve : Icons.resolve,
            barIcon: isOn ? Icons.resolveFill : Icons.resolve,
            swipeIcon2: isOn ? Icons.unresolveFill : Icons.resolveFill
        )
    }
    
    /// Adds or removes a user as administrator
    /// - Parameter isOn: true when user is admin, false otherwise
    static func addAdmin(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Remove Administrator" : "Appoint Administrator",
            isDestructive: isOn,
            color: isOn ? .themedNegative : .themedPositive,
            icon: isOn ? Icons.removeAdministrator : Icons.administration,
            swipeIcon1: isOn ? Icons.removeAdministrator : Icons.administration,
            swipeIcon2: isOn ? Icons.removeAdministratorFill : Icons.administrationFill
        )
    }
    
    /// Adds or removes a user as moderator
    /// - Parameter isOn: true when user is moderator, false otherwise
    static func addMod(isOn: Bool) -> Self {
        .init(
            label: isOn ? "Remove Moderator" : "Appoint Moderator",
            color: isOn ? .themedNegative : .themedPositive,
            icon: isOn ? Icons.demoteModerator : Icons.moderation,
            swipeIcon1: isOn ? Icons.demoteModerator : Icons.moderation,
            swipeIcon2: isOn ? Icons.demoteModeratorFill : Icons.moderationFill
        )
    }
    
    static func purge(isInProgress: Bool = false) -> Self {
        .init(
            label: "Purge",
            isInProgress: isInProgress,
            isDestructive: true,
            color: .themedWarning,
            icon: Icons.purge
        )
    }
    
    static func purgePerson(isInProgress: Bool = false) -> Self {
        .init(
            label: "Purge User",
            isInProgress: isInProgress,
            isDestructive: true,
            color: .themedWarning,
            icon: Icons.purge
        )
    }
    
    static func crossPost() -> Self {
        .init(label: "Crosspost", color: .themedAccent, icon: Icons.crossPost)
    }
    
    static func viewVotes() -> Self {
        .init(label: "View Votes", color: .themedAccent, icon: Icons.votes)
    }
        
    static func collapse() -> Self {
        .init(
            label: "Collapse",
            color: .themedColorfulAccent(4),
            icon: Icons.collapse,
            swipeIcon1: Icons.collapseSquare,
            swipeIcon2: Icons.collapseSquareFill
        )
    }
    
    static func collapseParent() -> Self {
        .init(
            label: "Collapse Parent",
            color: .themedColorfulAccent(4),
            icon: Icons.collapseParent,
            swipeIcon1: Icons.collapseParentSquare,
            swipeIcon2: Icons.collapseParentSquareFill
        )
    }
    
    static func collapseToTop() -> Self {
        .init(
            label: "Collapse to Top",
            color: .themedColorfulAccent(4),
            icon: Icons.collapseToTop,
            swipeIcon1: Icons.collapseToTopSquare,
            swipeIcon2: Icons.collapseToTopSquareFill
        )
    }
}
