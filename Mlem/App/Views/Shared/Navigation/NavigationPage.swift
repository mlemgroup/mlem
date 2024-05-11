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
    case quickSwitcher, addAccount
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
            LoginInstancePickerView()
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
        case .addAccount:
            LandingPage()
        }
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .addAccount:
            false
        default:
            true
        }
    }
}
