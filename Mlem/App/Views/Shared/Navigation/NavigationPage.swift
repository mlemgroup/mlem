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
    case feeds(_ selection: FeedSelection = .all)
    case profile, inbox, search
    case quickSwitcher
    case expandedPost(_ post: AnyPost, commentActorId: URL? = nil)
    case community(_ community: AnyCommunity)
    case person(_ person: AnyPerson)
    case instance(_ instance: InstanceHashWrapper)
    case externalApiInfo(api: ApiClient, actorId: URL)
    case imageViewer(_ url: URL)
    case communityPicker(callback: HashWrapper<(Community2) -> Void>)
    case personPicker(callback: HashWrapper<(Person2) -> Void>)
    case instancePicker(callback: HashWrapper<(InstanceSummary) -> Void>)
    case selectText(_ string: String)
    case subscriptionList
    case createComment(_ context: CommentEditorView.Context, expandedPostTracker: ExpandedPostTracker? = nil)
    case editComment(_ comment: Comment2, context: CommentEditorView.Context?)
    case report(_ interactable: ReportableHashWrapper, community: AnyCommunity? = nil)
    
    static func expandedPost(_ post: any PostStubProviding, commentActorId: URL? = nil) -> NavigationPage {
        expandedPost(.init(post), commentActorId: commentActorId)
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
    
    static func communityPicker(callback: @escaping (Community2) -> Void) -> NavigationPage {
        communityPicker(callback: .init(wrappedValue: callback))
    }
    
    static func personPicker(callback: @escaping (Person2) -> Void) -> NavigationPage {
        personPicker(callback: .init(wrappedValue: callback))
    }
    
    static func instancePicker(callback: @escaping (InstanceSummary) -> Void) -> NavigationPage {
        instancePicker(callback: .init(wrappedValue: callback))
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
}

extension NavigationPage {
    // swiftlint:disable:next cyclomatic_complexity function_body_length
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
        case let .feeds(feedSelection):
            FeedsView(feedSelection: feedSelection)
        case let .community(community):
            CommunityView(community: community)
        case .profile:
            ProfileView()
        case .inbox:
            InboxView()
        case .search:
            SearchView()
        case let .externalApiInfo(api: api, actorId: actorId):
            ExternalApiInfoView(api: api, actorId: actorId)
        case let .imageViewer(url):
            ImageViewer(url: url)
        case .quickSwitcher:
            QuickSwitcherView()
        case let .report(target, community):
            ReportComposerView(target: target.wrappedValue, community: community)
        case let .expandedPost(post, commentActorId):
            ExpandedPostView(post: post, showCommentWithActorId: commentActorId)
        case let .person(person):
            PersonView(person: person)
        case let .createComment(context, expandedPostTracker):
            if let view = CommentEditorView(context: context, expandedPostTracker: expandedPostTracker) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
        case let .editComment(comment, context: context):
            if let view = CommentEditorView(commentToEdit: comment, context: context) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
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
        case let .instancePicker(callback: callback):
            SearchSheetView { (instance: InstanceSummary, dismiss: DismissAction) in
                InstanceListRowBody(instance)
                    .onTapGesture {
                        callback.wrappedValue(instance)
                        dismiss()
                    }
                    .padding(.vertical, 6)
            }
        case let .instance(instance):
            InstanceView(instance: instance.wrappedValue)
        }
    }
    
    var hasNavigationStack: Bool {
        switch self {
        case .quickSwitcher, .report, .externalApiInfo, .selectText, .createComment, .editComment:
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
