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
        case let .logIn(page):
            page.view()
        case let .signUp(instance):
            SignUpView(instance: instance.wrappedValue)
        case let .feeds(feedSelection):
            FeedsView(feedSelection: feedSelection)
        case let .community(community):
            CommunityView(community: community)
        case let .crossPostList(post):
            CrossPostListPage(post: post)
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
        case let .post(post, highlightedComment, communityContext, navigationNamespace):
            ExpandedPostView(post: post, highlightedComment: highlightedComment?.wrappedValue)
                .environment(\.communityContext, communityContext?.wrappedValue)
                .navigationTransition_(sourceID: "post\(post.wrappedValue.actorId)", in: navigationNamespace)
        case let .person(person):
            PersonView(person: person)
        case let .createComment(context, commentTreeTracker):
            if let view = CommentEditorView(context: context, commentTreeTracker: commentTreeTracker) {
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
        case let .editPost(post):
            PostEditorView(postToEdit: post, community: nil)
        case let .communityPicker(api: api, callback: callback):
            SearchSheetView(api: api) { (community: Community2, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(community, navigation)
                } label: {
                    CommunityListRowBody(community, readout: .subscribers)
                        .tint(Palette.main.primary)
                }
                .padding(.vertical, 6)
            }
        case let .personPicker(api: api, callback: callback):
            SearchSheetView(api: api) { (person: Person2, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(person, navigation)
                } label: {
                    PersonListRowBody(person)
                        .tint(Palette.main.primary)
                }
                .padding(.vertical, 6)
            }
        case let .instancePicker(callback: callback, minimumVersion: minimumVersion):
            SearchSheetView { (instance: InstanceSummary, navigation: NavigationLayer) in
                Button {
                    callback.wrappedValue(instance, navigation)
                } label: {
                    InstanceListRowBody(instance)
                        .tint(Palette.main.primary)
                }
                .padding(.vertical, 6)
                .disabled(instance.version < (minimumVersion ?? .zero))
            } header: {
                if let minimumVersion {
                    Text("This feature is only supported for instances running version \(minimumVersion) or later.")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.main.caution.opacity(0.2), in: .rect(cornerRadius: Constants.main.standardSpacing))
                        .foregroundStyle(Palette.main.caution)
                        .padding([.horizontal, .bottom])
                }
            }
        case let .instance(instance):
            InstanceView(instance: instance.wrappedValue)
        case let .deleteAccount(account):
            DeleteAccountView(account: account)
        case let .bypassImageProxy(callback):
            BypassProxyWarningSheet(callback: callback.wrappedValue)
        }
    }
}
