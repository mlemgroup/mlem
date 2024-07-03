//
//  SettingsPage.swift
//  Mlem
//
//  Created by Sjmarf on 07/05/2024.
//

import SwiftUI

enum SettingsPage: Hashable {
    case root, accounts, account, theme, post, subscriptionList
    
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
        case .post:
            PostSettingsView()
        case .subscriptionList:
            SubscriptionListSettingsView()
        }
    }
}
