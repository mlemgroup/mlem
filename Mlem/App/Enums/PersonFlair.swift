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
    case accountAge(Date)
    
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
        case .accountAge: 8
        }
    }
    
    var text: String {
        switch self {
        case let .accountAge(created):
            var components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: created,
                to: .now
            ).roundingDownToMostSignificantComponent()
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.maximumUnitCount = 1
            formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
            return formatter.string(from: components) ?? ""
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
        case let .accountAge(date): AccountAgeBracket(date: date).color
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
        case let .accountAge(date): AccountAgeBracket(date: date).icon
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
        case let .accountAge(date): "Account Created \(date.formatted(date: .abbreviated, time: .omitted))"
        }
    }
    
    var textView: Text {
        (Text(Image(icon: icon)) + Text(text).fontWeight(.semibold))
            .foregroundStyle(color)
    }
}

private enum AccountAgeBracket: CaseIterable {
    case upToOneMonth
    case upToOneYear
    case upToTwoYears // In future we could increase this to three years?
    case other
    case beforeInflux
    
    init(date: Date) {
        if date < Date(timeIntervalSince1970: 1_685_617_200) { // 2023-06-01
            self = .beforeInflux
            return
        }
        
        let intervalSinceCreation = Date.now.timeIntervalSince(date)
        let day: TimeInterval = 24 * 60 * 60

        if intervalSinceCreation < 30 * day {
            self = .upToOneMonth
        } else if intervalSinceCreation < 365 * day {
            self = .upToOneYear
        } else if intervalSinceCreation < 2 * 365 * day {
            self = .upToTwoYears
        } else {
            self = .other
        }
    }
    
    var icon: Icon {
        switch self {
        case .upToOneMonth: .lemmy.newAccountFlair
        case .upToOneYear: .init("camera.macro")
        case .upToTwoYears: .init("tree.fill")
        case .other: .init("mountain.2.fill")
        case .beforeInflux: .init("fossil.shell.fill")
        }
    }
    
    var color: ThemedColor {
        .themedAccountAgeColor(Self.allCases.firstIndex(of: self)!)
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
