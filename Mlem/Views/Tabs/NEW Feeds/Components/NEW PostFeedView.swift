//
//  NEW PostFeedView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-13.
//

import Foundation
import SwiftUI

struct NewPostFeedView: View {
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("showReadPosts") var showReadPosts: Bool = true
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("postSize") var postSize: PostSize = .large
    
    @ObservedObject var postTracker: StandardPostTracker
    @Binding var postSortType: PostSortType
    let showCommunity: Bool
    
    @State var errorDetails: ErrorDetails?
    
    var body: some View {
        content
            .onChange(of: showReadPosts) { newValue in
                if newValue {
                    Task {
                        await postTracker.removeFilter(.read)
                    }
                } else {
                    Task {
                        await postTracker.applyFilter(.read)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    ForEach(genEllipsisMenuFunctions()) { menuFunction in
                        MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                    }
                    Menu {
                        ForEach(genPostSizeSwitchingFunctions()) { menuFunction in
                            MenuButton(menuFunction: menuFunction, confirmDestructive: nil)
                        }
                    } label: {
                        Label("Post Size", systemImage: Icons.postSizeSetting)
                    }
                }
            }
    }
    
    var content: some View {
        LazyVStack(spacing: 0) {
            if postTracker.items.isEmpty {
                noPostsView()
            } else {
                ForEach(postTracker.items, id: \.uid) { feedPost(for: $0) }
                EndOfFeedView(loadingState: postTracker.loadingState, viewType: .hobbit)
            }
        }
    }
    
    @ViewBuilder
    private func feedPost(for post: PostModel) -> some View {
        VStack(spacing: 0) {
            // TODO: reenable nav
            NavigationLink(.newPostLinkWithContext(.init(post: post, community: nil))) {
                FeedPost(
                    post: post,
                    community: post.community,
                    showPostCreator: shouldShowPostCreator,
                    showCommunity: showCommunity
                )
            }
            
            Divider()
        }
        .onAppear { postTracker.loadIfThreshold(post) }
        .buttonStyle(EmptyButtonStyle()) // Make it so that the link doesn't mess with the styling
    }
    
    @ViewBuilder
    private func noPostsView() -> some View {
        VStack {
            if postTracker.loadingState == .loading { // don't show posts until site information loads to avoid jarring redraw
                LoadingView(whatIsLoading: .posts)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else if let errorDetails {
                ErrorView(errorDetails)
                    .frame(maxWidth: .infinity)
            } else {
                NewNoPostsView(loadingState: postTracker.loadingState, postSortType: $postSortType, showReadPosts: $showReadPosts)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .padding(.top, 25)
            }
        }
        .animation(.easeOut(duration: 0.1), value: postTracker.loadingState)
    }
}
