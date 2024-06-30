//
//  PersonFlair.swift
//  Mlem
//
//  Created by Sjmarf on 28/06/2024.
//

import SwiftUI

enum PersonFlair {
    case admin
    case bot
    case bannedFromInstance
    case bannedFromCommunity
    case moderator
    case developer
    case op
    
    var color: Color {
        switch self {
        case .admin:
            return .teal
        case .moderator:
            return Palette.main.moderation
        case .op:
            return .orange
        case .bot:
            return .indigo
        case .bannedFromInstance, .bannedFromCommunity:
            return .red
        case .developer:
            return .purple
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
    
    var label: String {
        switch self {
        case .admin:
            return "Administrator"
        case .bot:
            return "Bot Account"
        case .bannedFromInstance:
            return "Banned"
        case .bannedFromCommunity:
            return "Banned from Community"
        case .moderator:
            return "Moderator"
        case .developer:
            return "Mlem Developer"
        case .op:
            return "Original Poster"
        }
    }
}
