//
//  UserContentFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Dependencies
import Foundation
import SwiftUI

enum UserContentFeedType: String, CaseIterable, Identifiable {
    case all, posts, comments
    
    var id: String { rawValue }
}

struct UserContentFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    
    @EnvironmentObject var appState: AppState
    
    @EnvironmentObject var userContentTracker: UserContentTracker

    @State var errorDetails: ErrorDetails?
    
    var contentType: UserContentFeedType = .all
    
    var items: [UserContentModel] {
        switch contentType {
        case .all:
            userContentTracker.items
        case .posts:
            userContentTracker.items.filter { $0.uid.contentType == .post }
        case .comments:
            userContentTracker.items.filter { $0.uid.contentType == .comment }
        }
    }
    
    var body: some View {
        content
            .animation(.easeOut(duration: 0.2), value: userContentTracker.items.isEmpty)
            .task { await userContentTracker.loadMoreItems() }
    }
    
    var content: some View {
        LazyVStack(spacing: 0) {
            if userContentTracker.items.isEmpty {
                noPostsView()
            } else {
                ForEach(items, id: \.uid) { feedItem(for: $0) }
                EndOfFeedView(loadingState: userContentTracker.loadingState, viewType: .hobbit, whatIsLoading: .posts)
            }
        }
    }
  
    @ViewBuilder
    private func feedItem(for item: UserContentModel) -> some View {
        Group {
            switch item {
            case let .post(postModel): feedPost(for: postModel)
            case let .comment(hierarchicalComment): feedComment(for: hierarchicalComment)
            }
        }
        .onAppear { userContentTracker.loadIfThreshold(item) }
    }
    
    @ViewBuilder
    private func feedPost(for postModel: PostModel) -> some View {
        VStack(spacing: 0) {
            // NavigationLink(.postLinkWithContext(.init(post: post, community: nil, postTracker: nil))) {
            NavigationLink(.lazyLoadPostLinkWithContext(.init(postId: postModel.postId))) {
                FeedPost(
                    post: postModel,
                    postTracker: nil, // TODO: enable filtering on these posts--low priority because sort of silly to filter your saved feed
                    showPostCreator: shouldShowPostCreator,
                    showCommunity: true
                )
            }
            
            Divider()
        }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
    }
    
    @ViewBuilder
    private func feedComment(for hierarchicalComment: HierarchicalComment) -> some View {
        VStack(spacing: 0) {
            NavigationLink(.lazyLoadPostLinkWithContext(.init(
                postId: hierarchicalComment.commentView.post.id,
                scrollTarget: hierarchicalComment.id
            ))) {
                CommentItem(
                    commentTracker: nil,
                    hierarchicalComment: hierarchicalComment,
                    postContext: nil,
                    communityContext: nil,
                    indentBehaviour: .never,
                    showPostContext: true,
                    showCommentCreator: false
                )
            }
            
            Divider()
        }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            if userContentTracker.loadingState == .loading ||
                (userContentTracker.items.isEmpty && userContentTracker.loadingState == .idle) {
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else if userContentTracker.loadingState == .done {
                // NoPostsView(loadingState: postTracker.loadingState)
                Text("No items :(")
                    .padding(.top, 20)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: userContentTracker.loadingState)
    }
}
