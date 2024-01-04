//
//  Opened Post.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

enum PossibleStyling {
    case bold, italics
}

private struct AnchorsKey: PreferenceKey {
    // Each key is a comment id. The corresponding value is the
    // .center anchor of that row.
    typealias Value = [Int: Anchor<CGPoint>]

    static var defaultValue: Value { [:] }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

// swiftlint:disable type_body_length
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
    
    @AppStorage("upvoteOnSave") var upvoteOnSave: Bool = false
    
    @AppStorage("showCommentJumpButton") var showCommentJumpButton: Bool = true
    @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    @StateObject var commentTracker: CommentTracker = .init()
    @EnvironmentObject var postTracker: PostTracker
    @State var post: PostModel
    var community: CommunityModel?
    
    @State var commentErrorDetails: ErrorDetails?
    
    @State var isLoading: Bool = false
    
    /// When this is set, the view scrolls to the comment with the given ID, or to the top if set to 0.
    @State var scrollTarget: Int?
    /// The id of the top visible comment, or 0 if the post is visible.
    @State var topVisibleCommentId: Int?

    @State private var sortSelection = 0
    @State var commentSortingType: CommentSortType = .appStorageValue()
    @State private var postLayoutMode: LargePost.LayoutMode = .maximize
    
    @State private var scrollToTopAppeared = false
    @Namespace var scrollToTop
    
    var body: some View {
        contentView
            .environmentObject(commentTracker)
            .navigationBarTitle(post.community.name, displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) { toolbarMenu }
            }
            .task { await loadComments() }
            .task { await postTracker.markRead(post: post) }
            .refreshable { await refreshComments() }
            .onChange(of: commentSortingType) { newSortingType in
                withAnimation(.easeIn(duration: 0.4)) {
                    commentTracker.comments = sortComments(commentTracker.comments, by: newSortingType)
                }
            }
    }
    
    private var contentView: some View {
        GeometryReader { proxy in
            ScrollViewReader { (scrollProxy: ScrollViewProxy) in
                ScrollView {
                    ScrollToView(appeared: $scrollToTopAppeared)
                        .id(scrollToTop)

                    VStack(spacing: 0) {
                        postView
                            .id(0)
                            .anchorPreference(
                                key: AnchorsKey.self,
                                value: .center
                            ) { [0: $0] }
                        
                        Divider()
                            .background(.black)
                        
                        if commentTracker.comments.isEmpty {
                            noCommentsView()
                        } else {
                            commentsView
                                .onAppear {
                                    if let target = scrollTarget {
                                        scrollTarget = nil
                                        scrollProxy.scrollTo(target, anchor: .top)
                                    }
                                }
                        }
                    }
                    .padding(.bottom, AppConstants.expandedPostOverscroll)
                }
                .onChange(of: scrollTarget) { target in
                    if let target {
                        scrollTarget = nil
                        withAnimation {
                            scrollProxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
                .onPreferenceChange(AnchorsKey.self) { anchors in
                    topVisibleCommentId = topCommentRow(of: anchors, in: proxy)
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
        .overlay {
            if showCommentJumpButton, commentTracker.comments.count > 1 {
                JumpButtonView(onShortPress: scrollToNextComment, onLongPress: scrollToPreviousComment)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: commentJumpButtonSide.alignment
                    )
            }
        }
        .fancyTabScrollCompatible()
        .navigationBarColor()
    }
    
    func scrollToNextComment() {
        if let topVisibleId = topVisibleCommentId {
            if topVisibleId == 0 {
                scrollTarget = commentTracker.topLevelIDs.first
                return
            }
            if let topLevelId = commentTracker.topLevelIDMap[topVisibleId] {
                if let index = commentTracker.topLevelIDs.firstIndex(of: topLevelId) {
                    if index + 1 < commentTracker.comments.count {
                        scrollTarget = commentTracker.topLevelIDs[index + 1]
                    }
                }
            }
        }
    }
    
    func scrollToPreviousComment() {
        if let topVisibleId = topVisibleCommentId {
            if topVisibleId == commentTracker.topLevelIDs.first {
                scrollTarget = 0
                return
            }
            
            if let topLevelId = commentTracker.topLevelIDMap[topVisibleId] {
                if let index = commentTracker.topLevelIDs.firstIndex(of: topLevelId) {
                    if index - 1 >= 0 {
                        scrollTarget = commentTracker.topLevelIDs[index - 1]
                    }
                }
            }
        }
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

    /// Displays the post itself, plus a little divider to keep it visually distinct from comments
    private var postView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                HStack {
                    CommunityLinkView(
                        community: post.community,
                        serverInstanceLocation: communityServerInstanceLocation
                    )
                    
                    Spacer()
                    
                    EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
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
                
                UserLinkView(
                    user: post.creator,
                    serverInstanceLocation: userServerInstanceLocation,
                    communityContext: community
                )
            }
            .padding(.top, AppConstants.postAndCommentSpacing)
            .padding(.horizontal, AppConstants.postAndCommentSpacing)
            
            InteractionBarView(
                votes: post.votes,
                published: post.published,
                updated: post.updated,
                numReplies: post.numReplies,
                saved: post.saved,
                accessibilityContext: "post",
                widgets: layoutWidgetTracker.groups.post,
                upvote: upvotePost,
                downvote: downvotePost,
                save: savePost,
                reply: replyToPost,
                shareURL: URL(string: post.post.apId),
                shouldShowScore: shouldShowScoreInPostBar,
                showDownvotesSeparately: showPostDownvotesSeparately,
                shouldShowTime: shouldShowTimeInPostBar,
                shouldShowSaved: shouldShowSavedInPostBar,
                shouldShowReplies: shouldShowRepliesInPostBar
            )
        }
    }

    /// Displays a "no comments" message
    @ViewBuilder
    private func noCommentsView() -> some View {
        if let details = commentErrorDetails {
            ErrorView(details)
        } else if isLoading {
            LoadingView(whatIsLoading: .comments)
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

    /// Displays the comments
    private var commentsView: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(commentTracker.commentsView, id: \.commentView.comment.id) { comment in
                CommentItem(
                    hierarchicalComment: comment,
                    postContext: post,
                    showPostContext: false,
                    showCommentCreator: true
                )
                .anchorPreference(
                    key: AnchorsKey.self,
                    value: .center
                ) { [comment.commentView.comment.id: $0] }
                /// [2023.08] Manually set zIndex so child comments don't overlap parent comments on collapse/expand animations. `Int.max` doesn't work, which is why this is set to just some big value.
                .zIndex(.maxZIndex - Double(comment.depth))
            }
        }
    }
    
    private func topCommentRow(of anchors: AnchorsKey.Value, in proxy: GeometryProxy) -> Int? {
        var yBest = CGFloat.infinity
        var answer: Int?
        for (row, anchor) in anchors {
            let y = proxy[anchor].y
            guard y >= 0, y < yBest else { continue }
            answer = row
            yBest = y
        }
        return answer
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

// swiftlint:enable type_body_length
