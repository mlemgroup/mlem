//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import MlemMiddleware
import SwiftUI

enum NavigationPage: Hashable {
    case settings(_ page: SettingsPage = .root)
    case feeds, profile, inbox, search
    case quickSwitcher
    /// Ask the user to login. If no instance if provided, one will be
    case login(_ details: LoginDetails)
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case let .settings(page):
            page.view()
        case let .login(details):
            if let instance = details.instance {
                LoginCredentialsView(instance: instance)
            } else if let user = details.user {
                LoginCredentialsView(userStub: user)
            } else {
                LoginInstancePickerView()
            }
        case .feeds:
            FeedsView()
        case .profile:
            ProfileView()
        case .inbox:
            Text("Inbox")
        case .search:
            SubscriptionListView()
        case .quickSwitcher:
            QuickSwitcherView()
                .presentationDetents([.medium, .large])
        }
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher:
            false
        default:
            true
        }
    }
}
