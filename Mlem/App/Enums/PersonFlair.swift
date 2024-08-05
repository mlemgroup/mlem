//
//  UserFlair.swift
//  Mlem
//
//  Created by Sjmarf on 07/10/2023.
//

import MlemMiddleware
import SwiftUI

enum PersonFlair: CaseIterable {
    // The order in which these cases are defined is the order in which they will appear
    case admin
    case moderator
    case developer
    case bot
    case op
    case bannedFromInstance
    case bannedFromCommunity
    
    var color: Color {
        switch self {
        case .admin:
            return Palette.main.administration
        case .moderator:
            return Palette.main.moderation
        case .op:
            return Palette.main.accent2
        case .bot:
            return Palette.main.accent7
        case .bannedFromInstance, .bannedFromCommunity:
            return Palette.main.negative
        case .developer:
            return Palette.main.accent6
        }
    }
    
    var icon: String {
        switch self {
        case .admin:
            return Icons.adminFlair
        case .moderator:
            return Icons.moderationFill
        case .op:
            return Icons.opFlair
        case .bot:
            return Icons.botFlair
        case .bannedFromInstance:
            return Icons.instanceBannedFlair
        case .bannedFromCommunity:
            return Icons.communityBannedFlair
        case .developer:
            return Icons.developerFlair
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .admin: "Administrator"
        case .bot: "Bot Account"
        case .bannedFromInstance: "Banned"
        case .bannedFromCommunity: "Banned from Community"
        case .moderator: "Moderator"
        case .developer: "Mlem Developer"
        case .op: "Original Poster"
        }
    }
}
