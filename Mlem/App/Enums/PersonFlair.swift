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
    case cakeDay
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
        case .cakeDay:
            return Palette.main.accent3
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
        case .cakeDay:
            return Icons.cakeDayFill
        }
    }
    
    var label: LocalizedStringResource {
        switch self {
        case .admin: "Administrator"
        case .bot: "Bot Account"
        case .bannedFromInstance: "Banned from Instance"
        case .bannedFromCommunity: "Banned from Community"
        case .moderator: "Moderator"
        case .developer: "Mlem Developer"
        case .op: "Original Poster"
        case .cakeDay: "Cake Day"
        }
    }
}

extension [PersonFlair] {
    func textView() -> Text {
        var text = Text(verbatim: "")
        if isEmpty { return text }
        for flair in self {
            // swiftlint:disable:next shorthand_operator
            text = text + Text(Image(systemName: flair.icon))
                .foregroundStyle(flair.color)
        }
        // swiftlint:disable:next shorthand_operator
        text = text + Text(verbatim: " ")
        return text
    }
}