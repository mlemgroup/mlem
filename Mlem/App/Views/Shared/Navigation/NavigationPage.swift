//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import SwiftUI

enum NavigationPage: Hashable {
    case feeds, profile, inbox, search, settings, quickSwitcher, addAccount
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .feeds:
            FeedsView()
        case .profile:
            ProfileView()
        case .inbox:
            Text("Inbox")
        case .search:
            Text("Search")
        case .settings:
            Text("Settings")
        case .quickSwitcher:
            QuickSwitcherView()
                .presentationDetents([.medium, .large])
        case .addAccount:
            LandingPage()
        }
    }
    
    var hasNavigationStack: Bool { false }
}
