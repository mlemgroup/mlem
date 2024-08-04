//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

enum SettingsPage: Hashable {
    case root, accounts, account, theme, post, links, subscriptionList, icon
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .root:
            SettingsView()
        case .account:
            AccountSettingsView()
        case .accounts:
            AccountListSettingsView()
        case .theme:
            ThemeSettingsView()
        case .icon:
            IconSettingsView()
        case .post:
            PostSettingsView()
        case .links:
            LinkSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        }
    }
}
