//
//  UserFlair.swift
//  Mlem
//
//  Created by Sjmarf on 07/10/2023.
//

import MlemMiddleware
import SwiftUI

enum PersonFlair: Hashable {
    // The order in which these cases are defined is the order in which they will appear
    case admin
    case moderator
    case developer
    case bot
    case op
    case cakeDay
    case bannedFromInstance
    case bannedFromCommunity
    case new(Int)
    
    var sortVal: Int {
        switch self {
        case .admin: 0
        case .moderator: 1
        case .developer: 2
        case .bot: 3
        case .op: 4
        case .cakeDay: 5
        case .bannedFromInstance: 6
        case .bannedFromCommunity: 7
        case .new: 8
        }
    }
    
    var text: String {
        switch self {
        case let .new(days): "\(days.description)d"
        default: ""
        }
    }
    
    var color: Color {
        switch self {
        case .admin:
            return Palette.main.administration
        case .moderator:
            return Palette.main.moderation
        case .op:
            return Palette.main.colorfulAccent(0)
        case .bot:
            return Palette.main.colorfulAccent(5)
        case .bannedFromInstance, .bannedFromCommunity:
            return Palette.main.negative
        case .developer:
            return Palette.main.colorfulAccent(4)
        case .cakeDay:
            return Palette.main.colorfulAccent(1)
        case .new:
            return Palette.main.colorfulAccent(3)
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
        case .new:
            return Icons.newAccountFlair
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
        case .new: "New Account"
        }
    }
}

extension [PersonFlair] {
    func textView() -> Text {
        var text = Text(verbatim: "")
        if isEmpty { return text }
        for flair in self {
            // swiftlint:disable:next shorthand_operator
            text = text + (Text(Image(systemName: flair.icon)) + Text(flair.text).fontWeight(.semibold))
                .foregroundStyle(flair.color)
        }
        // swiftlint:disable:next shorthand_operator
        text = text + Text(verbatim: " ")
        return text
    }
}
