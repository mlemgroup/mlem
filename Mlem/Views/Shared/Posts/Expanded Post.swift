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

private struct AnchorsKey: PreferenceKey {
    // Each key is a comment id. The corresponding value is the
    // .center anchor of that row.
    typealias Value = [Int: Anchor<CGPoint>]

    static var defaultValue: Value { [:] }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct ExpandedPost: View {
    
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
    // appstorage
    @AppStorage("defaultCommentSorting") var defaultCommentSorting: CommentSortType = .top
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = false
    
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = true
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    @AppStorage("showCommentJumpButton") var showCommentJumpButton: Bool = true
    @AppStorage("commentJumpButtonSide") var commentJumpButtonSide: JumpButtonLocation = .bottomTrailing

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
    
    /// When this is set, the view scrolls to the comment with the given ID, or to the top if set to 0.
    @State var scrollTarget: Int?
    /// The id of the top visible comment, or 0 if the post is visible.
    @State var topVisibleCommentId: Int?

    @State private var sortSelection = 0
    @State private var commentSortingType: CommentSortType = .top
    
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
        ZStack(alignment: commentJumpButtonSide == .bottomTrailing ? .bottomTrailing : .bottomLeading) {
            GeometryReader { proxy in
                ScrollViewReader { (scrollProxy: ScrollViewProxy) in
                    ScrollView {
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
                    }
                    .onChange(of: scrollTarget) { target in
                        if let target = target {
                            scrollTarget = nil
                            withAnimation {
                                scrollProxy.scrollTo(target, anchor: .top)
                            }
                        }
                    }
                    .onPreferenceChange(AnchorsKey.self) { anchors in
                        topVisibleCommentId = topCommentRow(of: anchors, in: proxy)
                    }
                }
                .listStyle(PlainListStyle())
            }
            if showCommentJumpButton && commentTracker.comments.count > 1 {
                JumpButtonView(onShortPress: scrollToNextComment, onLongPress: scrollToPreviousComment)
            }
        }
        .fancyTabScrollCompatible()
    }
    
    func scrollToNextComment() {
        if let topVisibleId = topVisibleCommentId {
            var nextComment: HierarchicalComment?
            
            if topVisibleId == 0 {
                nextComment = commentTracker.commentsView.first
            } else {
                if let index = commentTracker.commentsView.firstIndex(where: { $0.commentView.comment.id == topVisibleId }) {
                    nextComment = commentTracker.commentsView[(index+1)...].first(where: { $0.depth == 0 })
                }
            }
            if let nextComment = nextComment {
                scrollTarget = nextComment.commentView.comment.id
            }
        }
    }
    
    func scrollToPreviousComment() {
        if topVisibleCommentId == commentTracker.comments.first?.commentView.comment.id {
            scrollTarget = 0
        }
        if let topVisibleCommentId = topVisibleCommentId {
            if let index = commentTracker.commentsView.firstIndex(where: { $0.commentView.comment.id == topVisibleCommentId }) {
                if let previousComment = commentTracker.commentsView[..<index].last(where: { $0.depth == 0 }) {
                    scrollTarget = previousComment.commentView.comment.id
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
                    isExpanded: true
                )
                
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
