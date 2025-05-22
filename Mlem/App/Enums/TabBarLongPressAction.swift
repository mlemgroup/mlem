//
//  TabBarLongPressAction.swift
//  Mlem
//
// Created by Bedir Ekim on 21.05.2025.
//

import Foundation
import Icons

enum TabBarLongPressAction: String, CaseIterable, Codable {
    case openAccountSwitcher, switchToMostRecentAccount
    
    var label: LocalizedStringResource {
        switch self {
        case .openAccountSwitcher: "Open Account Switcher"
        case .switchToMostRecentAccount: "Switch to Most Recent Account"
        }
    }
    
    var icon: Icon {
        switch self {
        case .openAccountSwitcher: .lemmy.openAccountSwitcher
        case .switchToMostRecentAccount: .lemmy.switchAccount
        }
    }
}
