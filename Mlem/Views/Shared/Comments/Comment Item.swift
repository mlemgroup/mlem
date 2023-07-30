//
//  Comment Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import Dependencies
import SwiftUI

struct CommentItem: View {
    
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    // appstorage
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    @AppStorage("compactComments") var compactComments: Bool = false
    
    // MARK: Environment

    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var appState: AppState

    // MARK: Constants

    let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    let indent: CGFloat = 10

    // MARK: Parameters

    var hierarchicalComment: HierarchicalComment
    let postContext: APIPostView? // TODO: redundant with comment.post?
    let depth: Int
    let showPostContext: Bool
    let showCommentCreator: Bool
    let enableSwipeActions: Bool
    
    // MARK: Computed

    // init needed to get dirty and clean aligned
    init(hierarchicalComment: HierarchicalComment,
         postContext: APIPostView?,
         depth: Int,
         showPostContext: Bool,
         showCommentCreator: Bool,
         enableSwipeActions: Bool = true
    ) {
        self.hierarchicalComment = hierarchicalComment
        self.postContext = postContext
        self.depth = depth
        self.showPostContext = showPostContext
        self.showCommentCreator = showCommentCreator
        self.enableSwipeActions = enableSwipeActions
    }

    // MARK: State

    @State var isCollapsed: Bool = false

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    CommentBodyView(commentView: hierarchicalComment.commentModel,
                                    isCollapsed: isCollapsed,
                                    showPostContext: showPostContext,
                                    menuFunctions: genMenuFunctions())
                    // top and bottom spacing uses default even when compact--it's *too* compact otherwise
                    .padding(.top, AppConstants.postAndCommentSpacing)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)

                    if !isCollapsed && !compactComments {
                        CommentInteractionBar(commentView: hierarchicalComment.commentModel,
                                              upvote: upvote,
                                              downvote: downvote,
                                              saveComment: saveComment,
                                              deleteComment: deleteComment,
                                              replyToComment: replyToComment)
                    } else {
                        Spacer()
                            .frame(height: AppConstants.postAndCommentSpacing)
                    }
                }
            }
            .contentShape(Rectangle()) // allow taps in blank space to register
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4)) {
                    // Perhaps we want an explict flag for this in the future?
                    if !showPostContext {
                        isCollapsed.toggle()
                    }
                }
            }
            .contextMenu {
                ForEach(genMenuFunctions()) { item in
                    Button {
                        item.callback()
                    } label: {
                        Label(item.text, systemImage: item.imageName)
                    }
                }
            }
            .background(Color.systemBackground)
            .addSwipeyActions(primaryLeadingAction: enableSwipeActions ? upvoteSwipeAction : nil,
                              secondaryLeadingAction: enableSwipeActions ? downvoteSwipeAction : nil,
                              primaryTrailingAction: enableSwipeActions ? saveSwipeAction : nil,
                              secondaryTrailingAction: enableSwipeActions ? replySwipeAction : nil
            )
            .border(width: depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[depth % threadingColors.count])
            
            Divider()

            childComments
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        .clipped()
        .padding(.leading, depth == 0 ? 0 : indent)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: Subviews

    @ViewBuilder
    var commentBody: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            // comment text or placeholder
            if hierarchicalComment.commentModel.deleted {
                Text("Comment was deleted")
                    .italic()
                    .foregroundColor(.secondary)
            } else if hierarchicalComment.commentModel.comment.removed {
                Text("Comment was removed")
                    .italic()
                    .foregroundColor(.secondary)
            } else if !isCollapsed {
                MarkdownView(text: hierarchicalComment.commentModel.comment.content, isNsfw: hierarchicalComment.commentModel.post.nsfw)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            // embedded post
            if showPostContext {
                EmbeddedPost(
                    community: hierarchicalComment.commentModel.community,
                    post: hierarchicalComment.commentModel.post
                )
            }
        }
    }

    @ViewBuilder
    var childComments: some View {
        if !isCollapsed {
            // lazy stack because there might be *lots* of these
            LazyVStack(spacing: 0) {
                ForEach(hierarchicalComment.children, id: \.commentModel.hashValue) { child in
                    CommentItem(
                        hierarchicalComment: child,
                        postContext: postContext,
                        depth: depth + 1,
                        showPostContext: false,
                        showCommentCreator: true
                    )
                }
            }
        }
    }
}

// MARK: - Swipe Actions

extension CommentItem {
    
    private var emptyVoteSymbolName: String { hierarchicalComment.commentModel.votes.myVote == .upvote
        ? "minus.square"
        : "arrow.up.square" }
    private var upvoteSymbolName: String { hierarchicalComment.commentModel.votes.myVote == .upvote
        ? "minus.square.fill"
        : "arrow.up.square.fill" }
    private var emptyDownvoteSymbolName: String { hierarchicalComment.commentModel.votes.myVote == .downvote
        ? "minus.square"
        : "arrow.down.square" }
    private var downvoteSymbolName: String { hierarchicalComment.commentModel.votes.myVote == .downvote
        ? "minus.square.fill"
        : "arrow.down.square.fill" }
    private var emptySaveSymbolName: String { hierarchicalComment.commentModel.saved
        ? "bookmark.slash"
        : "bookmark" }
    private var saveSymbolName: String { hierarchicalComment.commentModel.saved
        ? "bookmark.slash.fill"
        : "bookmark.fill" }
    private var emptyReplySymbolName: String { "arrowshape.turn.up.left" }
    private var replySymbolName: String { "arrowshape.turn.up.left.fill" }
    
    var upvoteSwipeAction: SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: emptyVoteSymbolName, fillName: upvoteSymbolName),
            color: .upvoteColor,
            action: upvote
        )
    }
    
    var downvoteSwipeAction: SwipeAction? {
        guard appState.enableDownvote else { return nil }
        return SwipeAction(
            symbol: .init(emptyName: emptyDownvoteSymbolName, fillName: downvoteSymbolName),
            color: .downvoteColor,
            action: downvote
        )
    }
    
    var saveSwipeAction: SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: emptySaveSymbolName, fillName: saveSymbolName),
            color: .saveColor,
            action: saveComment
        )
    }

    var replySwipeAction: SwipeAction? {
        return SwipeAction(
            symbol: .init(emptyName: emptyReplySymbolName, fillName: replySymbolName),
            color: .accentColor,
            action: replyToCommentAsyncWrapper
        )
    }
}
