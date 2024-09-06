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
    case signUp
    case feeds(_ selection: FeedSelection? = nil)
    case profile, inbox, search
    case quickSwitcher
    case expandedPost(_ post: AnyPost, commentActorId: URL? = nil, communityContext: HashWrapper<any Community1Providing>? = nil)
    case community(_ community: AnyCommunity)
    case person(_ person: AnyPerson)
    case instance(_ instance: InstanceHashWrapper)
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case communityPicker(api: ApiClient?, callback: HashWrapper<(Community2, NavigationLayer) -> Void>)
    case personPicker(api: ApiClient?, callback: HashWrapper<(Person2, NavigationLayer) -> Void>)
    case instancePicker(callback: HashWrapper<(InstanceSummary, NavigationLayer) -> Void>)
    case selectText(_ string: String)
    case subscriptionList
    case createComment(_ context: CommentEditorView.Context, expandedPostTracker: ExpandedPostTracker? = nil)
    case editComment(_ comment: Comment2, context: CommentEditorView.Context?)
    case report(_ interactable: ReportableHashWrapper, community: AnyCommunity? = nil)
    case createPost(community: AnyCommunity?)
    case deleteAccount(_ account: UserAccount)
    
    static func expandedPost(_ post: any PostStubProviding, commentActorId: URL? = nil) -> NavigationPage {
        expandedPost(.init(post), commentActorId: commentActorId)
    }
    
    static func expandedPost(_ post: any PostStubProviding, communityContext: (any Community1Providing)?) -> NavigationPage {
        if let communityContext {
            expandedPost(.init(post), communityContext: .init(wrappedValue: communityContext))
        } else {
            expandedPost(.init(post))
        }
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
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community2, NavigationLayer) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: callback))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        callback: @escaping (Person2, NavigationLayer) -> Void
    ) -> NavigationPage {
        personPicker(api: api, callback: .init(wrappedValue: callback))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary, NavigationLayer) -> Void
    ) -> NavigationPage {
        instancePicker(callback: .init(wrappedValue: callback))
    }
    
    static func communityPicker(
        api: ApiClient? = nil,
        callback: @escaping (Community2) -> Void
    ) -> NavigationPage {
        communityPicker(api: api, callback: .init(wrappedValue: { value, navigation in
            callback(value)
            navigation.dismissSheet()
        }))
    }
    
    static func personPicker(
        api: ApiClient? = nil,
        callback: @escaping (Person2) -> Void
    ) -> NavigationPage {
        personPicker(api: api, callback: .init(wrappedValue: { value, navigation in
            callback(value)
            navigation.dismissSheet()
        }))
    }
    
    static func instancePicker(
        callback: @escaping (InstanceSummary) -> Void
    ) -> NavigationPage {
        instancePicker(callback: .init(wrappedValue: { value, navigation in
            callback(value)
            navigation.dismissSheet()
        }))
    }
    
    static func createPost(community: any CommunityStubProviding) -> NavigationPage {
        createPost(community: .init(community))
    }

    static func report(_ interactable: any ReportableProviding, community: (any CommunityStubProviding)?) -> NavigationPage {
        let anyCommunity: AnyCommunity?
        if let community {
            anyCommunity = .init(community)
        } else {
            anyCommunity = nil
        }
        return report(.init(wrappedValue: interactable), community: anyCommunity)
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .report, .externalApiInfo, .selectText, .createComment, .editComment, .createPost:
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

struct ReportableHashWrapper: Hashable {
    var wrappedValue: any ReportableProviding
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue.hashValue)
    }
    
    static func == (lhs: ReportableHashWrapper, rhs: ReportableHashWrapper) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
