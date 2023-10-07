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
    case banned
    case moderator
    case developer
    case op
    
    var color: Color {
        switch self {
        case .admin:
            return .pink
        case .moderator:
            return .green
        case .op:
            return .orange
        case .bot:
            return .indigo
        case .banned:
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
        case .banned:
            return Icons.bannedFlair
        case .developer:
            return Icons.developerFlair
        }
    }
}
