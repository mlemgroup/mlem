//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

enum ResolveProgress {
    case waiting, failed
}

struct ExpandedPost: View {
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    
    // appstorage
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
        
    @AppStorage("showCommentJumpButton") var showCommentJumpButton: Bool = true
    @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing

    @Environment(AppState.self) var appState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @State var post: any PostStubProviding
    
    @State var resolveProgress: ResolveProgress?
    
    @State var commentErrorDetails: ErrorDetails?
    
    @State private var sortSelection = 0
    @State var commentSortingType: CommentSortType = .appStorageValue()
    @State private var postLayoutMode: LargePost.LayoutMode = .maximize
    
    @State private var scrollToTopAppeared = false
    @Namespace var scrollToTop
    
    var body: some View {
        contentView
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) { toolbarMenu }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 10) {
                        switch resolveProgress {
                        case .failed:
                            Text("Failed to resolve")
                                .foregroundStyle(.red)
                        case nil, .waiting:
                            Text(post.community_?.name ?? "Loading...")
                                .opacity(resolveProgress == .waiting ? 0.5 : 1)
                                .animation(.easeOut(duration: 0.2), value: resolveProgress)
                        }
                    }
                    .font(.headline)
                }
            }
            .onChange(of: appState.actorId) {
                if let source = appState.apiSource {
                    resolveProgress = .waiting
                    Task {
                        do {
                            print("Resolving post...")
                            let newPost = PostStub(source: source, actorId: post.actorId)
                            let shouldKeepId = post.source.actorId.host() == newPost.source.actorId.host()
                            let upgraded = try await newPost.upgrade(id: shouldKeepId ? post.id_ : nil)
                            DispatchQueue.main.async {
                                print("Resolved post!")
                                self.post = upgraded
                                self.resolveProgress = nil
                            }
                        } catch {
                            DispatchQueue.main.async {
                                resolveProgress = .failed
                            }
                        }
                    }
                }
            }
    }
    
    private var contentView: some View {
        GeometryReader { _ in
            ScrollViewReader { (scrollProxy: ScrollViewProxy) in
                ScrollView {
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)

                    if let post = post as? any Post2Providing {
                        VStack(spacing: 0) {
                            postView(post: post)
                            Divider()
                                .background(.black)
                            noCommentsView()
                        }
                        .padding(.bottom, AppConstants.expandedPostOverscroll)
                    }
                }
                .hoistNavigation {
                    if scrollToTopAppeared {
                        return false
                    } else {
                        withAnimation {
                            scrollProxy.scrollTo(scrollToTop)
                        }
                        return true
                    }
                }
            }
        }
        .fancyTabScrollCompatible()
        .navigationBarColor()
    }
    
    var userServerInstanceLocation: ServerInstanceLocation {
        shouldShowUserServerInPost ? .bottom : .disabled
    }
    
    var communityServerInstanceLocation: ServerInstanceLocation {
        shouldShowCommunityServerInPost ? .bottom : .disabled
    }
    
    // MARK: Subviews

    /// Displays the post itself, plus a little divider to keep it visually distinct from comments
    @ViewBuilder
    private func postView(post: any Post2Providing) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                HStack {
                    CommunityLinkView(
                        community: post.community,
                        serverInstanceLocation: communityServerInstanceLocation
                    )
                
                    Spacer()
                    
                    EllipsisMenu(size: 24, menuFunctions: post.menuFunctions)
                }
                
                LargePost(
                    post: post,
                    layoutMode: $postLayoutMode
                )
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.25)) {
                        postLayoutMode = postLayoutMode == .maximize ? .minimize : .maximize
                    }
                }
                
                PersonLinkView(
                    person: post.creator,
                    serverInstanceLocation: userServerInstanceLocation,
                    communityContext: post.community
                )
            }
            .padding(.top, AppConstants.postAndCommentSpacing)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            
            InteractionBarView(
                content: post,
                accessibilityContext: "post",
                widgets: layoutWidgetTracker.groups.post,
                reply: { },
                // reply: replyToPost
                shouldShowScore: shouldShowScoreInPostBar,
                showDownvotesSeparately: showPostDownvotesSeparately,
                shouldShowTime: shouldShowTimeInPostBar,
                shouldShowSaved: shouldShowSavedInPostBar,
                shouldShowReplies: shouldShowRepliesInPostBar
            )
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
        }
    }

    /// Displays a "no comments" message
    @ViewBuilder
    private func noCommentsView() -> some View {
        if let details = commentErrorDetails {
            ErrorView(details)
        } else {
            VStack(spacing: 2) {
                VStack(spacing: 5) {
                    Image(systemName: Icons.noContent)
                    Text("No comments to be found")
                }
                Text("Why not post the first one?")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }
    
    private var toolbarMenu: some View {
        Menu {
            ForEach(CommentSortType.allCases, id: \.self) { type in
                Button {
                    commentSortingType = type
                } label: {
                    Label(type.description, systemImage: type.iconName)
                }
                .disabled(type == commentSortingType)
            }

        } label: {
            Label(commentSortingType.description, systemImage: commentSortingType.iconName)
        }
    }
}
