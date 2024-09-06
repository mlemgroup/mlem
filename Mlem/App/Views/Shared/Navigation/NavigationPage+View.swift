//
//  NavigationPage+View.swift
//  Mlem
//
//  Created by Sjmarf on 28/04/2024.
//

import MlemMiddleware
import SwiftUI

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
        case .signUp:
            SignUpView()
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
        case let .expandedPost(post, commentActorId, communityContext):
            ExpandedPostView(post: post, showCommentWithActorId: commentActorId)
                .environment(\.communityContext, communityContext?.wrappedValue)
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
        case let .createPost(community: community):
            if let view = PostEditorView(community: community) {
                view
            } else {
                Text(verbatim: "Error: No active UserAccount")
            }
        case let .communityPicker(api: api, callback: callback):
            SearchSheetView(api: api) { (community: Community2, navigation: NavigationLayer) in
                CommunityListRowBody(community)
                    .onTapGesture {
                        callback.wrappedValue(community, navigation)
                    }
                    .padding(.vertical, 6)
            }
        case let .personPicker(api: api, callback: callback):
            SearchSheetView(api: api) { (person: Person2, navigation: NavigationLayer) in
                PersonListRowBody(person)
                    .onTapGesture {
                        callback.wrappedValue(person, navigation)
                    }
                    .padding(.vertical, 6)
            }
        case let .instancePicker(callback: callback):
            SearchSheetView { (instance: InstanceSummary, navigation: NavigationLayer) in
                InstanceListRowBody(instance)
                    .onTapGesture {
                        callback.wrappedValue(instance, navigation)
                    }
                    .padding(.vertical, 6)
            }
        case let .instance(instance):
            InstanceView(instance: instance.wrappedValue)
        case let .deleteAccount(account):
            DeleteAccountView(account: account)
        }
    }
}

extension NavigationPage {
    @ViewBuilder
    func viewWithModifiers(layer: NavigationLayer) -> some View {
        view()
            .sheet(isPresented: Binding(
                get: { (layer.model?.layers.count ?? 0) > (layer.index + 1)
                    && !(layer.model?.layers[layer.index + 1].isFullScreenCover ?? true)
                },
                set: { newValue in
                    if !newValue, let model = layer.model {
                        model.layers.removeLast(max(0, model.layers.count - layer.index - 1))
                    }
                }
            )) {
                if let model = layer.model {
                    NavigationLayerView(layer: model.layers[layer.index + 1], hasSheetModifiers: true)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { (layer.model?.layers.count ?? 0) > (layer.index + 1)
                    && (layer.model?.layers[layer.index + 1].isFullScreenCover ?? false)
                },
                set: { newValue in
                    if !newValue, let model = layer.model {
                        model.layers.removeLast(max(0, model.layers.count - layer.index - 1))
                    }
                }
            )) {
                if let model = layer.model {
                    NavigationLayerView(layer: model.layers[layer.index + 1], hasSheetModifiers: true)
                }
            }
    }
}
