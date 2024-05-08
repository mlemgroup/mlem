//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

enum NavigationPage: Hashable {
    case settings(_ page: SettingsPage = .root)
    case feeds, profile, inbox, search
    case quickSwitcher, addAccount
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case let .settings(page):
            page.view()
        case .feeds:
            FeedsView()
        case .profile:
            ProfileView()
        case .inbox:
            Text("Inbox")
        case .search:
            Text("Search")
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
