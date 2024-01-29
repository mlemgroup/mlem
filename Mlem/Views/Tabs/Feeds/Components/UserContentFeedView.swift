//
//  UserContentFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-28.
//

import Dependencies
import Foundation
import SwiftUI

struct UserContentFeedView: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    @AppStorage("fallbackDefaultPostSorting") var fallbackDefaultPostSorting: PostSortType = .hot
    
    @EnvironmentObject var appState: AppState
    
    @StateObject var userContentTracker: UserContentTracker

    @State var errorDetails: ErrorDetails?
    
    @Binding var selectedFeed: FeedType?
    
    @Namespace var scrollToTop
    @State private var scrollToTopAppeared = false
    private var scrollToTopId: Int? {
        userContentTracker.items.first?.uid.hashValue
    }
    
    init(userId: Int, saved: Bool, selectedFeed: Binding<FeedType?>) {
        @AppStorage("internetSpeed") var internetSpeed: InternetSpeed = .fast
        self._userContentTracker = .init(wrappedValue: .init(internetSpeed: internetSpeed, userId: userId, saved: saved))
        self._selectedFeed = selectedFeed
    }
    
    var body: some View {
        content
            .task { await userContentTracker.loadMoreItems() }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Menu {
                        ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                            MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                        }
                    } label: {
                        Label("Post Size", systemImage: Icons.postSizeSetting)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    navBarTitle
                        .opacity(scrollToTopAppeared ? 0 : 1)
                        .animation(.easeOut(duration: 0.2), value: scrollToTopAppeared)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(visibility: .automatic)
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)
                    headerView
                        .padding(.top, -1)
                }
                
                LazyVStack(spacing: 0) {
                    if userContentTracker.items.isEmpty {
                        noPostsView()
                    } else {
                        ForEach(userContentTracker.items, id: \.uid) { feedItem(for: $0) }
                        EndOfFeedView(loadingState: userContentTracker.loadingState, viewType: .hobbit)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: userContentTracker.items.isEmpty)
                .animation(.easeOut(duration: 0.2), value: selectedFeed)
            }
        }
        .fancyTabScrollCompatible()
    }
    
    @ViewBuilder
    var headerView: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
            }
        } label: {
            FeedHeaderView(feedType: .saved)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    var navBarTitle: some View {
        Menu {
            ForEach(genFeedSwitchingFunctions()) { menuFunction in
                MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Text(FeedType.saved.label)
                    .font(.headline)
                Image(systemName: Icons.dropdown)
                    .scaleEffect(0.7)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.primary)
            .accessibilityElement(children: .combine)
            .accessibilityHint("Activate to change feeds.")
            // this disables the implicit animation on the header view...
            .transaction { $0.animation = nil }
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
            NavigationLink(.lazyLoadPostLinkWithContext(.init(post: postModel.post))) {
                FeedPost(
                    post: postModel,
                    community: nil,
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
            // NavigationLink(.postLinkWithContext(.init(post: post, community: nil, postTracker: nil))) {
            NavigationLink(.lazyLoadPostLinkWithContext(.init(post: hierarchicalComment.commentView.post, scrollTarget: hierarchicalComment.id))) {
                CommentItem(
                    hierarchicalComment: hierarchicalComment,
                    postContext: nil,
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
                Text("no items :(")
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.1), value: userContentTracker.loadingState)
    }
}
