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
    
    enum PageContext {
        case posts, profile
    }
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.commentRepository) var commentRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.siteInformation) var siteInformation
    @Dependency(\.hapticManager) var hapticManager
    
    // appstorage
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    @AppStorage("compactComments") var compactComments: Bool = false
    @AppStorage("collapseChildComments") var collapseComments: Bool = false

    // MARK: Temporary

    // state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
    @State var dirtyVote: ScoringOperation // = .resetVote
    @State var dirtyScore: Int // = 0
    @State var dirtySaved: Bool // = false
    @State var dirty: Bool = false
    
    @State var isCommentReplyHidden: Bool = false

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
    let postContext: PostModel? // TODO: redundant with comment.post?
    let indentBehaviour: IndentBehaviour
    var depth: Int { hierarchicalComment.depth < 0 ? 0 : hierarchicalComment.depth }
    let showPostContext: Bool
    let showCommentCreator: Bool
    let enableSwipeActions: Bool
    let pageContext: PageContext
    
    // MARK: Destructive confirmation
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
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
    init(
        hierarchicalComment: HierarchicalComment,
        postContext: PostModel?,
        indentBehaviour: IndentBehaviour = .standard,
        showPostContext: Bool,
        showCommentCreator: Bool,
        enableSwipeActions: Bool = true,
        pageContext: PageContext = .posts
    ) {
        self.hierarchicalComment = hierarchicalComment
        self.postContext = postContext
        self.indentBehaviour = indentBehaviour
        self.showPostContext = showPostContext
        self.showCommentCreator = showCommentCreator
        self.enableSwipeActions = enableSwipeActions
        self.pageContext = pageContext

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
                        commentBody(hierarchicalComment: hierarchicalComment)
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
                CommentBodyView(
                    commentView: hierarchicalComment.commentView,
                    isParentCollapsed: $hierarchicalComment.isParentCollapsed,
                    isCollapsed: $hierarchicalComment.isCollapsed,
                    showPostContext: showPostContext,
                    menuFunctions: genMenuFunctions(),
                    links: hierarchicalComment.links
                )
                // top and bottom spacing uses default even when compact--it's *too* compact otherwise
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                if !hierarchicalComment.isCollapsed, !compactComments {
                    InteractionBarView(
                        votes: VotesModel(from: hierarchicalComment.commentView.counts, myVote: hierarchicalComment.commentView.myVote),
                        published: hierarchicalComment.commentView.comment.published,
                        updated: hierarchicalComment.commentView.comment.updated,
                        numReplies: hierarchicalComment.commentView.counts.childCount,
                        saved: hierarchicalComment.commentView.saved,
                        accessibilityContext: "comment",
                        widgets: layoutWidgetTracker.groups.comment,
                        upvote: upvote,
                        downvote: downvote,
                        save: saveComment,
                        reply: replyToComment,
                        shareURL: URL(string: hierarchicalComment.commentView.comment.apId),
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
                
                if collapseComments,
                   pageContext == .posts,
                   !hierarchicalComment.isCollapsed,
                   hierarchicalComment.depth == 0,
                   hierarchicalComment.children.count > 0,
                   !isCommentReplyHidden {
                    Divider()
                    HStack {
                        CollapsedCommentReplies(numberOfReplies: .constant(hierarchicalComment.commentView.counts.childCount))
                            .onTapGesture {
                                isCommentReplyHidden = true
                                uncollapseComment()
                            }
                    }
                }
            }
        }
        .contentShape(Rectangle()) // allow taps in blank space to register
        .onTapGesture {
            if pageContext == .posts {
                toggleCollapsed()
            }
        }
        .destructiveConfirmation(
            isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
            confirmationMenuFunction: confirmationMenuFunction
        )
        .background(Color.systemBackground)
        .addSwipeyActions(
            leading: enableSwipeActions ? [upvoteSwipeAction, downvoteSwipeAction] : [],
            trailing: enableSwipeActions ? [saveSwipeAction, replySwipeAction, expandCollapseCommentAction] : []
        )
        .border(width: borderWidth, edges: [.leading], color: threadingColors[depth % threadingColors.count])
        .contextMenu {
            ForEach(genMenuFunctions()) { item in
                MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
            }
        }
        .onChange(of: collapseComments) { newValue in
            if pageContext == .posts {
                if newValue == false {
                    uncollapseComment()
                } else {
                    collapseComment()
                }
            }
        }
        .onDisappear {
            isCommentReplyHidden = false
        }
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
    private var emptyCollapseSymbolName: String { "arrow.up.and.line.horizontal.and.arrow.down" }
    private var collapseSymbolName: String { "arrow.up.and.line.horizontal.and.arrow.down" }
    private var emptyExpandSymbolName: String { "arrow.down.and.line.horizontal.and.arrow.up" }
    private var expandSymbolName: String { "arrow.down.and.line.horizontal.and.arrow.up" }
    
    var upvoteSwipeAction: SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: emptyVoteSymbolName, fillName: upvoteSymbolName),
            color: .upvoteColor,
            action: {
                Task {
                    await upvote()
                }
            }
        )
    }
    
    var downvoteSwipeAction: SwipeAction? {
        guard siteInformation.enableDownvotes else { return nil }
        return SwipeAction(
            symbol: .init(emptyName: emptyDownvoteSymbolName, fillName: downvoteSymbolName),
            color: .downvoteColor,
            action: {
                Task {
                    await downvote()
                }
            }
        )
    }
    
    var saveSwipeAction: SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: emptySaveSymbolName, fillName: saveSymbolName),
            color: .saveColor,
            action: {
                Task {
                    await saveComment()
                }
            }
        )
    }

    var replySwipeAction: SwipeAction? {
        SwipeAction(
            symbol: .init(emptyName: emptyReplySymbolName, fillName: replySymbolName),
            color: .accentColor,
            action: {
                Task {
                    await replyToCommentAsyncWrapper()
                }
            }
        )
    }
    
    var expandCollapseCommentAction: SwipeAction {
        SwipeAction(
            symbol: .init(
                emptyName: hierarchicalComment.isCollapsed ? emptyCollapseSymbolName : emptyExpandSymbolName,
                fillName: hierarchicalComment.isCollapsed ? collapseSymbolName : expandSymbolName
            ),
            color: .orange,
            action: toggleCollapsed
        )
    }
}
