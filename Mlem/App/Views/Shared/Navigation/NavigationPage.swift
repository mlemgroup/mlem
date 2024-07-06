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
    case community(_ community: AnyCommunity)
    case person(_ person: AnyPerson)
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case communityPicker(callback: HashWrapper<(Community2) -> Void>)
    case personPicker(callback: HashWrapper<(Person2) -> Void>)
    case communitySubscriptionManager
    case subscriptionList
    
    static func expandedPost(_ post: any PostStubProviding) -> NavigationPage {
        expandedPost(.init(post))
    }
    
    static func person(_ person: any PersonStubProviding) -> NavigationPage {
        Self.person(.init(person))
    }
    
    static func community(_ community: any CommunityStubProviding) -> NavigationPage {
        Self.community(.init(community))
    }
    
    static func communityPicker(callback: @escaping (Community2) -> Void) -> NavigationPage {
        communityPicker(callback: .init(wrappedValue: callback))
    }
    
    static func personPicker(callback: @escaping (Person2) -> Void) -> NavigationPage {
        personPicker(callback: .init(wrappedValue: callback))
    }
}

extension NavigationPage {
    // swiftlint:disable:next cyclomatic_complexity
    @ViewBuilder func view() -> some View {
        switch self {
        case .subscriptionList:
            SubscriptionListView()
        case let .settings(page):
            page.view()
        case let .login(page):
            page.view()
        case .feeds:
            FeedsView()
        case .community:
            FeedsView()
        case .profile:
            ProfileView()
        case .inbox:
            InboxView()
        case .search:
            EmptyView()
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
        case let .personPicker(callback: callback):
            SearchSheetView { (person: Person2, dismiss: DismissAction) in
                PersonListRowBody(person)
                    .onTapGesture {
                        callback.wrappedValue(person)
                        dismiss()
                    }
                    .padding(.vertical, 6)
            }
        case .communitySubscriptionManager:
            SubscriptionManagementView()
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
