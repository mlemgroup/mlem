//
//  Comment Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import Dependencies
import SwiftUI

struct CommentItem: View {
    
    enum IndentBehaviour {
        case standard, never
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    // appstorage
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = true
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("compactComments") var compactComments: Bool = false

    // MARK: Temporary
    // state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
    @State var dirtyVote: ScoringOperation // = .resetVote
    @State var dirtyScore: Int // = 0
    @State var dirtySaved: Bool // = false
    @State var dirty: Bool = false

    @State var isComposingReport: Bool = false

    // computed properties--if dirty, show dirty value, otherwise show post value
    var displayedVote: ScoringOperation { dirty ? dirtyVote : hierarchicalComment.commentView.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : hierarchicalComment.commentView.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : hierarchicalComment.commentView.saved }
    
    // MARK: Environment

    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker

    // MARK: Constants

    let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    let indent: CGFloat = 10

    // MARK: Parameters

    @ObservedObject var hierarchicalComment: HierarchicalComment
    let postContext: APIPostView? // TODO: redundant with comment.post?
    let indentBehaviour: IndentBehaviour
    var depth: Int { hierarchicalComment.depth < 0 ? 0 : hierarchicalComment.depth }
    let showPostContext: Bool
    let showCommentCreator: Bool
    let enableSwipeActions: Bool
    
    // MARK: Computed
    
    private var indentValue: CGFloat {
        if depth == 0 || indentBehaviour == .never {
            return 0
        } else {
            return CGFloat(hierarchicalComment.depth) * CGFloat(indent)
        }
    }

    private var borderWidth: CGFloat {
        if depth == 0 || indentBehaviour == .never {
            return 0
        } else {
            return 2
        }
    }

    // init needed to get dirty and clean aligned
    init(hierarchicalComment: HierarchicalComment,
         postContext: APIPostView?,
         indentBehaviour: IndentBehaviour = .standard,
         showPostContext: Bool,
         showCommentCreator: Bool,
         enableSwipeActions: Bool = true
    ) {
        self.hierarchicalComment = hierarchicalComment
        self.postContext = postContext
        self.indentBehaviour = indentBehaviour
        self.showPostContext = showPostContext
        self.showCommentCreator = showCommentCreator
        self.enableSwipeActions = enableSwipeActions

        _dirtyVote = State(initialValue: hierarchicalComment.commentView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: hierarchicalComment.commentView.counts.score)
        _dirtySaved = State(initialValue: hierarchicalComment.commentView.saved)
    }

    // MARK: Body
    
    // swiftlint:disable line_length
    var body: some View {
        Group {
            VStack(spacing: 0) {
                if hierarchicalComment.isParentCollapsed, hierarchicalComment.isCollapsed, hierarchicalComment.commentView.comment.parentId != nil {
                    EmptyView()
                } else if hierarchicalComment.isParentCollapsed, !hierarchicalComment.isCollapsed, hierarchicalComment.commentView.comment.parentId != nil {
                    EmptyView()
                } else {
                    Group {
                        commentBody(hierarchicalComment: self.hierarchicalComment)
                        Divider()
                    }
                    /// Clips any transitions to this view, otherwise comments will animate over other ones.
                    .clipped()
                    .padding(.leading, indentValue)
                    .transition(.commentView())
                }
            }
        }
    }
    // swiftlint:enable line_length

    // swiftlint:disable function_body_length
    // MARK: Subviews
    
    @ViewBuilder
    private func commentBody(hierarchicalComment: HierarchicalComment) -> some View {
        Group {
            VStack(alignment: .leading, spacing: 0) {
                CommentBodyView(commentView: hierarchicalComment.commentView,
                                isParentCollapsed: $hierarchicalComment.isParentCollapsed,
                                isCollapsed: $hierarchicalComment.isCollapsed,
                                showPostContext: showPostContext,
                                menuFunctions: genMenuFunctions())
                // top and bottom spacing uses default even when compact--it's *too* compact otherwise
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                if !hierarchicalComment.isCollapsed && !compactComments {
                    InteractionBarView(
                        apiView: hierarchicalComment.commentView,
                        accessibilityContext: "comment",
                        widgets: layoutWidgetTracker.groups.comment,
                        displayedScore: displayedScore,
                        displayedVote: displayedVote,
                        displayedSaved: displayedSaved,
                        upvote: upvote,
                        downvote: downvote,
                        save: saveComment,
                        reply: replyToComment,
                        share: {
                            if let url = URL(string: hierarchicalComment.commentView.comment.apId) {
                                showShareSheet(URLtoShare: url)
                            }
                        },
                        shouldShowScore: shouldShowScoreInCommentBar,
                        showDownvotesSeparately: showCommentDownvotesSeparately,
                        shouldShowTime: shouldShowTimeInCommentBar,
                        shouldShowSaved: shouldShowSavedInCommentBar,
                        shouldShowReplies: shouldShowRepliesInCommentBar
                    )
                } else {
                    Spacer()
                        .frame(height: AppConstants.postAndCommentSpacing)
                }
            }
        }
        .contentShape(Rectangle()) // allow taps in blank space to register
        .onTapGesture {
            withAnimation(.showHideComment(!hierarchicalComment.isCollapsed)) {
                // Perhaps we want an explict flag for this in the future?
                if !showPostContext {
                    commentTracker.setCollapsed(!hierarchicalComment.isCollapsed, comment: hierarchicalComment)
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
        .border(width: borderWidth, edges: [.leading], color: threadingColors[depth % threadingColors.count])
//        .sheet(isPresented: $isComposingReport) {
//            ResponseComposerView(concreteRespondable: ConcreteRespondable(appState: appState,
//                                                                          comment: hierarchicalComment.commentView,
//                                                                          report: true))
//        }
    }
    // swiftlint:enable function_body_length
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
        return SwipeAction(
            symbol: .init(emptyName: emptyReplySymbolName, fillName: replySymbolName),
            color: .accentColor,
            action: replyToCommentAsyncWrapper
        )
    }
}
