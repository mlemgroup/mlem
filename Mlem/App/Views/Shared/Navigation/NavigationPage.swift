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
    case login(_ page: LoginPage = .pickInstance)
    case feeds, profile, inbox, search
    case quickSwitcher
    case expandedPost(_ post: Post2)
}

extension NavigationPage {
    @ViewBuilder
    func view() -> some View {
        switch self {
        case let .settings(page):
            page.view()
        case let .login(page):
            page.view()
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
        case let .expandedPost(post):
            ExpandedPostView(post: post)
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
