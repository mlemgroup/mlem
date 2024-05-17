//
//  NavigationPage.swift
//  Mlem
//
//  Created by Sjmarf on 27/04/2024.
//

import MlemMiddleware
import SwiftUI

enum NavigationPage: Hashable {
    static func == (lhs: NavigationPage, rhs: NavigationPage) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    case settings(_ page: SettingsPage = .root)
    case feeds, profile, inbox, search
    case quickSwitcher, addAccount
    case expandedPost(_ post: AnyPost)
    
    static func expandedPost(_ post: any PostStubProviding) -> NavigationPage {
        expandedPost(.init(post: post))
    }
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
            SubscriptionListView()
        case .quickSwitcher:
            QuickSwitcherView()
                .presentationDetents([.medium, .large])
        case .addAccount:
            LandingPage()
        case let .expandedPost(post):
            ExpandedPostView(post: post)
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
