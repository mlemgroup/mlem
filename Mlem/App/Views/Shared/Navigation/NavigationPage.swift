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
    case expandedPost(_ post: AnyPost, commentId: Int? = nil)
    case community(_ community: AnyCommunity)
    case person(_ person: AnyPerson)
    case instance(_ instance: InstanceHashWrapper)
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case selectText(_ string: String)
    case subscriptionList
    
    static func expandedPost(_ post: any PostStubProviding, commentId: Int? = nil) -> NavigationPage {
        expandedPost(.init(post), commentId: commentId)
    }
    
    static func person(_ person: any PersonStubProviding) -> NavigationPage {
        Self.person(.init(person))
    }
    
    static func community(_ community: any CommunityStubProviding) -> NavigationPage {
        Self.community(.init(community))
    }
    
    static func instance(_ instance: any InstanceStubProviding) -> NavigationPage {
        Self.instance(.init(wrappedValue: instance))
    }
}

extension NavigationPage {
    // swiftlint:disable:next cyclomatic_complexity
    @ViewBuilder func view() -> some View {
        switch self {
        case .subscriptionList:
            SubscriptionListView()
        case let .selectText(string):
            SelectTextView(text: string)
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
            VStack {
                Link("Test", destination: URL(string: "https://lemmy.dbzer0.com")!)
                Text("\((AppState.main.firstSession as? UserSession)?.blocks?.instanceCount)")
            }
        case let .externalApiInfo(api: api, actorId: actorId):
            ExternalApiInfoView(api: api, actorId: actorId)
        case let .imageViewer(url):
            ImageViewer(url: url)
        case .quickSwitcher:
            QuickSwitcherView()
        case let .expandedPost(post, commentId):
            ExpandedPostView(post: post, showCommentWithId: commentId)
        case let .person(person):
            PersonView(person: person)
        case let .instance(instance):
            InstanceView(instance: instance.wrappedValue)
        }
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .externalApiInfo, .selectText:
            false
        default:
            true
        }
    }
    
    var canDisplayToasts: Bool {
        switch self {
        case .quickSwitcher, .externalApiInfo, .selectText:
            false
        default:
            true
        }
    }
}

struct InstanceHashWrapper: Hashable {
    var wrappedValue: any InstanceStubProviding
    let id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: InstanceHashWrapper, rhs: InstanceHashWrapper) -> Bool {
        lhs.id == rhs.id
    }
}
