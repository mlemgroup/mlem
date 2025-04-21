//
//  UserFlair.swift
//  Mlem
//
//  Created by Sjmarf on 07/10/2023.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

enum PersonFlair: Hashable {
    case admin
    case moderator
    case developer
    case bot
    case op
    case cakeDay
    case bannedFromInstance
    case bannedFromCommunity
    case new(TimeInterval)
    
    // this defines the order in which flairs appear
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
        case let .new(interval):
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.second, .minute, .hour, .day]
            formatter.maximumUnitCount = 1
            return formatter.string(from: interval) ?? ""
        default:
            return ""
        }
    }
    
    var color: ThemedColor {
        switch self {
        case .admin: .themedAdministration
        case .moderator: .themedModeration
        case .op: .themedColorfulAccent(0)
        case .bot: .themedColorfulAccent(5)
        case .bannedFromInstance, .bannedFromCommunity: .themedNegative
        case .developer: .themedColorfulAccent(4)
        case .cakeDay: .themedColorfulAccent(1)
        case .new: .themedColorfulAccent(3)
        }
    }
    
    var icon: Icon {
        switch self {
        case .admin: .lemmy.administration
        case .moderator: .lemmy.moderation
        case .op: .lemmy.opFlair
        case .bot: .lemmy.botFlair
        case .bannedFromInstance: .lemmy.bannedFromInstance
        case .bannedFromCommunity: .lemmy.bannedFromCommunity
        case .developer: .lemmy.developerFlair
        case .cakeDay: .lemmy.cakeDay
        case .new: .lemmy.newAccountFlair
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
    
    var textView: Text {
        (Text(Image(icon: icon)) + Text(text).fontWeight(.semibold))
            .foregroundStyle(color)
    }
}

extension [PersonFlair] {
    var textView: Text {
        if isEmpty {
            Text(verbatim: "")
        } else {
            reduce(Text(verbatim: "")) { $0 + $1.textView } + Text(verbatim: " ")
        }
    }
}
