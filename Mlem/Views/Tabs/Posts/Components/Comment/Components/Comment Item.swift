//
//  Comment Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct CommentItem: View {
    // appstorage
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false

    // MARK: Temporary
    // state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
    @State var dirtyVote: ScoringOperation // = .resetVote
    @State var dirtyScore: Int // = 0
    @State var dirtySaved: Bool // = false
    @State var dirty: Bool = false

    @State var isShowingAlert: Bool = false
    @State var isComposingReport: Bool = false

    // computed properties--if dirty, show dirty value, otherwise show post value
    var displayedVote: ScoringOperation { dirty ? dirtyVote : hierarchicalComment.commentView.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : hierarchicalComment.commentView.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : hierarchicalComment.commentView.saved }
    
    // MARK: Environment

    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var commentReplyTracker: CommentReplyTracker
    @EnvironmentObject var appState: AppState

    // MARK: Constants

    let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    let indent: CGFloat = 10

    // MARK: Parameters

    let hierarchicalComment: HierarchicalComment
    let postContext: APIPostView? // TODO: redundant with comment.post?
    let depth: Int
    let showPostContext: Bool
    let showCommentCreator: Bool
    let showInteractionBar: Bool
    let enableSwipeActions: Bool
    let replyToComment: ((APICommentView) -> Void)?

    @Binding var isDragging: Bool
    
    // MARK: Computed

    // init needed to get dirty and clean aligned
    init(hierarchicalComment: HierarchicalComment,
         postContext: APIPostView?,
         depth: Int,
         showPostContext: Bool,
         showCommentCreator: Bool,
         isDragging: Binding<Bool>,
         showInteractionBar: Bool = true,
         enableSwipeActions: Bool = true,
         replyToComment: ((APICommentView) -> Void)?
    ) {
        self.hierarchicalComment = hierarchicalComment
        self.postContext = postContext
        self.depth = depth
        self.showPostContext = showPostContext
        self.showCommentCreator = showCommentCreator
        self.showInteractionBar = showInteractionBar
        self.enableSwipeActions = enableSwipeActions
        self.replyToComment = replyToComment
        _isDragging = isDragging

        _dirtyVote = State(initialValue: hierarchicalComment.commentView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: hierarchicalComment.commentView.counts.score)
        _dirtySaved = State(initialValue: hierarchicalComment.commentView.saved)

//        let commentor = hierarchicalComment.commentView.creator
//        commentorLabel = "Last updated \(publishedAgo) ago by \(commentor.displayName ?? commentor.name)"
    }

    // MARK: State

    @State var isCollapsed: Bool = false

    // let commentorLabel: String

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            Group {
                VStack(alignment: .leading, spacing: 0) {
                    CommentBodyView(commentView: hierarchicalComment.commentView,
                                    isCollapsed: isCollapsed,
                                    showPostContext: showPostContext,
                                    showCommentCreator: showCommentCreator,
                                    menuFunctions: genMenuFunctions())
                    .padding(.top, AppConstants.postAndCommentSpacing)
                    .padding(.horizontal, AppConstants.postAndCommentSpacing)

                    if showInteractionBar {
                        CommentInteractionBar(commentView: hierarchicalComment.commentView,
                                              displayedScore: displayedScore,
                                              displayedVote: displayedVote,
                                              displayedSaved: displayedSaved,
                                              upvote: upvote,
                                              downvote: downvote,
                                              saveComment: saveComment,
                                              deleteComment: deleteComment,
                                              replyToComment: replyToCommentUnwrapped)
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
            .addSwipeyActions(
                isDragging: $isDragging,
                primaryLeadingAction: enableSwipeActions ? upvoteSwipeAction : nil,
                secondaryLeadingAction: enableSwipeActions ? downvoteSwipeAction : nil,
                primaryTrailingAction: enableSwipeActions ? saveSwipeAction : nil,
                secondaryTrailingAction: enableSwipeActions ? replySwipeAction : nil
            )
            .border(width: depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[depth % threadingColors.count])
            .sheet(isPresented: $isComposingReport) {
                ReportComposerView(reportedPost: nil, reportedComment: hierarchicalComment.commentView)
            }
            
            Divider()

            childComments
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        .clipped()
        .padding(.leading, depth == 0 ? 0 : indent)
        .transition(.move(edge: .top).combined(with: .opacity))
        .alert("Not yet implemented!", isPresented: $isShowingAlert) {
            Button("I love beta apps", role: .cancel) { }
        }
    }

    // MARK: Subviews

    @ViewBuilder
    var commentBody: some View {
        VStack(spacing: AppConstants.postAndCommentSpacing) {
            // comment text or placeholder
            if hierarchicalComment.commentView.comment.deleted {
                Text("Comment was deleted")
                    .italic()
                    .foregroundColor(.secondary)
            } else if hierarchicalComment.commentView.comment.removed {
                Text("Comment was removed")
                    .italic()
                    .foregroundColor(.secondary)
            } else if !isCollapsed {
                MarkdownView(text: hierarchicalComment.commentView.comment.content, isNsfw: hierarchicalComment.commentView.post.nsfw)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            // embedded post
            if showPostContext {
                EmbeddedPost(
                    community: hierarchicalComment.commentView.community,
                    post: hierarchicalComment.commentView.post
                )
            }
        }
    }

    @ViewBuilder
    var childComments: some View {
        if !isCollapsed {
            // lazy stack because there might be *lots* of these
            LazyVStack(spacing: 0) {
                ForEach(hierarchicalComment.children) { child in
                    CommentItem(
                        hierarchicalComment: child,
                        postContext: postContext,
                        depth: depth + 1,
                        showPostContext: false,
                        showCommentCreator: true,
                        isDragging: $isDragging,
                        replyToComment: replyToComment
                    )
                }
            }
        }
    }
}

// MARK: - Swipe Actions

extension CommentItem {
    
    private var emptyVoteSymbolName: String { displayedVote == .upvote ? "minus.square" : "arrow.up.square" }
    private var upvoteSymbolName: String { displayedVote == .upvote ? "minus.square.fill" : "arrow.up.square.fill" }
    private var emptyDownvoteSymbolName: String { displayedVote == .downvote ? "minus.square" : "arrow.down.square" }
    private var downvoteSymbolName: String { displayedVote == .downvote ? "minus.square.fill" : "arrow.down.square.fill" }
    private var emptySaveSymbolName: String { displayedSaved ? "bookmark.slash" : "bookmark" }
    private var saveSymbolName: String { displayedSaved ? "bookmark.slash.fill" : "bookmark.fill" }
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
        if replyToComment != nil {
            return SwipeAction(
                symbol: .init(emptyName: emptyReplySymbolName, fillName: replySymbolName),
                color: .accentColor,
                action: replyToCommentAsyncWrapper
            )
        } else {
            return nil
        }
    }
}
