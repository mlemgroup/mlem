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
    case login(_ page: LoginPage = .pickInstance)
    case feeds, profile, inbox, search
    case quickSwitcher
    case expandedPost(_ post: AnyPost)
    case person(_ person: AnyPerson)
    
    static func expandedPost(_ post: any PostStubProviding) -> NavigationPage {
        .expandedPost(.init(post: post))
    }
    
    static func person(_ person: any PersonStubProviding) -> NavigationPage {
        .person(.init(person: person))
    }
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
            InboxView()
        case .search:
            SubscriptionListView()
        case .quickSwitcher:
            QuickSwitcherView()
                .presentationDetents([.medium, .large])
        case let .expandedPost(post):
            ExpandedPostView(post: post)
        case let .person(person):
            PersonView(person: person.person)
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
    
    var canDisplayToasts: Bool {
        switch self {
        case .quickSwitcher:
            false
        default:
            true
        }
    }
}
