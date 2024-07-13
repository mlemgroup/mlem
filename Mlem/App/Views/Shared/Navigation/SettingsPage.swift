//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

enum SettingsPage: Hashable {
    case root, accounts, account, accountSwitching, theme, post, links, subscriptionList
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .root:
            SettingsView()
        case .account:
            AccountSettingsView()
        case .accounts:
            AccountListSettingsView()
        case .accountSwitching:
            AccountSwitchingSettingsView()
        case .theme:
            ThemeSettingsView()
        case .post:
            PostSettingsView()
        case .links:
            LinkSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        }
    }
}
