//
//  UserFlair.swift
//  Mlem
//
//  Created by Sjmarf on 07/10/2023.
//

import SwiftUI

enum UserFlair {
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
            return .green
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
            return Icons.bannedFlair
        case .bannedFromCommunity:
            return Icons.communityBan
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
