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
    case expandedPost(_ post: AnyPost)
    case person(_ person: AnyPerson)
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case communityPicker(callback: HashWrapper<(Community2) -> Void>)
    case communitySubscriptionManager
    
    static func expandedPost(_ post: any PostStubProviding) -> NavigationPage {
        expandedPost(.init(post))
    }
    
    static func person(_ post: any PersonStubProviding) -> NavigationPage {
        person(.init(post))
    }
}

extension NavigationPage {
    // swiftlint:disable:next cyclomatic_complexity
    @ViewBuilder func view() -> some View {
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
        case let .externalApiInfo(api: api, actorId: actorId):
            ExternalApiInfoView(api: api, actorId: actorId)
        case let .imageViewer(url):
            ImageViewer(url: url)
        case .quickSwitcher:
            QuickSwitcherView()
        case let .expandedPost(post):
            ExpandedPostView(post: post)
        case let .person(person):
            PersonView(person: person)
        case let .communityPicker(callback: callback):
            SearchSheetView { (community: Community2, dismiss: DismissAction) in
                CommunityListRowBody(community)
                    .onTapGesture {
                        callback.wrappedValue(community)
                        dismiss()
                    }
                    .padding(.vertical, 6)
            }
        case .communitySubscriptionManager:
            EmptyView()
        }
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .externalApiInfo:
            false
        default:
            true
        }
    }
    
    var canDisplayToasts: Bool {
        switch self {
        case .quickSwitcher, .externalApiInfo:
            false
        default:
            true
        }
    }
}

struct HashWrapper<Value>: Hashable, Identifiable {
    let wrappedValue: Value
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: HashWrapper, rhs: HashWrapper) -> Bool {
        lhs.id == rhs.id
    }
}
