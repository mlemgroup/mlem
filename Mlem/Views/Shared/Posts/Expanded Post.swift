//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

internal enum PossibleStyling {
    case bold, italics
}

struct ExpandedPost: View {
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.notifier) var notifier
    @Dependency(\.postRepository) var postRepository
    
    // appstorage
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = false
    
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = true
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @StateObject var commentTracker: CommentTracker = .init()
    @EnvironmentObject var postTracker: PostTracker
    @State var post: APIPostView
    
    @State var dirtyVote: ScoringOperation = .resetVote
    @State var dirtyScore: Int = 0
    @State var dirtySaved: Bool = false
    @State var dirty: Bool = false
    
    var displayedVote: ScoringOperation { dirty ? dirtyVote : post.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : post.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : post.saved }
    
    @State var isLoading: Bool = false

    @State private var sortSelection = 0
    @State var commentSortingType: CommentSortType = .appStorageValue()
    @State private var postLayoutMode: LargePost.LayoutMode = .maximize
    
    var body: some View {
        contentView
            .environmentObject(commentTracker)
            .navigationBarTitle(post.community.name, displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) { toolbarMenu }
            }
            .task { await loadComments() }
            .task { await markPostAsRead() }
            .refreshable { await refreshComments() }
            .onChange(of: commentSortingType) { newSortingType in
                withAnimation(.easeIn(duration: 0.4)) {
                    commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
                }
            }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 0) {
                postView
                    .id(post.hashValue)
                
                Divider()
                    .background(.black)

                if commentTracker.comments.isEmpty {
                    noCommentsView()
                } else {
                    commentsView
                }
            }
        }
        .listStyle(PlainListStyle())
        .fancyTabScrollCompatible()
        .navigationBarColor()
    }
    
    var userServerInstanceLocation: ServerInstanceLocation {
        if !shouldShowUserServerInPost {
            return .disabled
        } else {
            return .bottom
        }
    }
    
    var communityServerInstanceLocation: ServerInstanceLocation {
        if !shouldShowCommunityServerInPost {
            return .disabled
        } else {
            return .bottom
        }
    }
    
    // MARK: Subviews

    /**
     Displays the post itself, plus a little divider to keep it visually distinct from comments
     */
    private var postView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                HStack {
                    CommunityLinkView(
                        community: post.community,
                        serverInstanceLocation: communityServerInstanceLocation)
                    
                    Spacer()
                    
                    EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                }
                
                LargePost(
                    postView: post,
                    layoutMode: $postLayoutMode
                )
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.25)) {
                        postLayoutMode = postLayoutMode == .maximize ? .minimize : .maximize
                    }
                }
                
                UserProfileLink(user: post.creator,
                                serverInstanceLocation: userServerInstanceLocation)
            }
            .padding(.top, AppConstants.postAndCommentSpacing)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            
            InteractionBarView(
                apiView: post,
                accessibilityContext: "post",
                widgets: layoutWidgetTracker.groups.post,
                displayedScore: displayedScore,
                displayedVote: displayedVote,
                displayedSaved: displayedSaved,
                upvote: upvotePost,
                downvote: downvotePost,
                save: savePost,
                reply: replyToPost,
                share: {
                    if let url = URL(string: post.post.apId) {
                        showShareSheet(URLtoShare: url)
                    }
                },
                shouldShowScore: shouldShowScoreInPostBar,
                showDownvotesSeparately: showPostDownvotesSeparately,
                shouldShowTime: shouldShowTimeInPostBar,
                shouldShowSaved: shouldShowSavedInPostBar,
                shouldShowReplies: shouldShowRepliesInPostBar
            )
        }
    }

    /**
     Displays a "no comments" message
     */
    @ViewBuilder
    private func noCommentsView() -> some View {
        if isLoading {
            LoadingView(whatIsLoading: .comments)
        } else {
            VStack(spacing: 2) {
                VStack(spacing: 5) {
                    Image(systemName: "binoculars")
                    Text("No comments to be found")
                }
                Text("Why not post the first one?")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
            .padding()
        }
    }

    /**
     Displays the comments
     */
    private var commentsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(commentTracker.commentsView, id: \.commentView.comment.hashValue) { comment in
                CommentItem(
                    hierarchicalComment: comment,
                    postContext: post,
                    showPostContext: false,
                    showCommentCreator: true
                )
                /// [2023.08] Manually set zIndex so child comments don't overlap parent comments on collapse/expand animations. `Int.max` doesn't work, which is why this is set to just some big value.
                .zIndex(.maxZIndex - Double(comment.depth))
            }
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
