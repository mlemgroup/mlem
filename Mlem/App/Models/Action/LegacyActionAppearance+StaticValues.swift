//
//  ActionAppearance+StaticValues.swift
//  Mlem
//
//  Created by Sjmarf on 16/08/2024.
//

import Foundation

extension LegacyActionAppearance {

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
}
