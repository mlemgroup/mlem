//
//  Comment Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct CommentItem: View {
    //appstorage
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    // MARK: Temporary
    //state fakers--these let the upvote/downvote/score/save views update instantly even if the call to the server takes longer
    @State var dirtyVote: ScoringOperation // = .resetVote
    @State var dirtyScore: Int // = 0
    @State var dirtySaved: Bool // = false
    @State var dirty: Bool = false
    
    @State var isShowingAlert: Bool = false
    
    // computed properties--if dirty, show dirty value, otherwise show post value
    var displayedVote: ScoringOperation { dirty ? dirtyVote : hierarchicalComment.commentView.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : hierarchicalComment.commentView.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : hierarchicalComment.commentView.saved }
    
    // TODO: init instead of computed when backend changes come through--this nested computed business is expensive
    var emptyVoteSymbolName: String { displayedVote == .upvote ? "minus.square" : "arrow.up.square" }
    var upvoteSymbolName: String { displayedVote == .upvote ? "minus.square.fill" : "arrow.up.square.fill" }
    var downvoteSymbolName: String { displayedVote == .downvote ? "minus.square.fill" : "arrow.down.square.fill" }
    var emptySaveSymbolName: String { displayedSaved ? "bookmark.slash" : "bookmark" }
    var saveSymbolName: String { displayedSaved ? "bookmark.slash.fill" : "bookmark.fill" }
    
    // MARK: Environment

    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var commentReplyTracker: CommentReplyTracker
    @EnvironmentObject var appState: AppState
    
    // MARK: Constants
    
    let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    let spacing: CGFloat = 8
    let indent: CGFloat = 10
    
    // MARK: Parameters
    
    let account: SavedAccount
    let hierarchicalComment: HierarchicalComment
    let postContext: APIPostView?
    let depth: Int
    let showPostContext: Bool
    
    @Binding var isDragging: Bool
    
    // init needed to get dirty and clean aligned
    init(account: SavedAccount, hierarchicalComment: HierarchicalComment, postContext: APIPostView?, depth: Int, showPostContext: Bool, isDragging: Binding<Bool>) {
        self.account = account
        self.hierarchicalComment = hierarchicalComment
        self.postContext = postContext
        self.depth = depth
        self.showPostContext = showPostContext
        _isDragging = isDragging
        
        _dirtyVote = State(initialValue: hierarchicalComment.commentView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: hierarchicalComment.commentView.counts.score)
        _dirtySaved = State(initialValue: hierarchicalComment.commentView.saved)
        
        publishedAgo = getTimeIntervalFromNow(date: hierarchicalComment.commentView.post.published )
        let commentor = hierarchicalComment.commentView.creator
        commentorLabel = "Last updated \(publishedAgo) ago by \(commentor.displayName ?? commentor.name)"
    }
    
    // MARK: State
    
    @State var isCollapsed: Bool = false
    
    // MARK: Computed
    
    var publishedAgo: String
    let commentorLabel: String
    
    // MARK: Body
    var body: some View {
        VStack(spacing: 0) {
            Group {
                VStack(spacing: spacing) {
                    commentHeader
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel(commentorLabel)
                        .foregroundColor(.secondary)
                    
                    commentBody
                    
                    CommentInteractionBar(commentView: hierarchicalComment.commentView,
                                          account: account,
                                          displayedScore: displayedScore,
                                          displayedVote: displayedVote,
                                          displayedSaved: displayedSaved,
                                          upvote: upvote,
                                          downvote: downvote,
                                          saveComment: saveComment,
                                          deleteComment: deleteComment)
                }
                .padding(spacing)
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
                Button("Upvote") {
                    Task(priority: .userInitiated) {
                        await upvote()
                    }
                }
                Button("Downvote") {
                    Task(priority: .userInitiated) {
                        await downvote()
                    }
                }
                Button("Save") {
                    Task(priority: .userInitiated) {
                        await saveComment()
                    }
                }
                Button("Reply") {
                    replyToComment()
                }
            }
            .background(Color.systemBackground)
            .addSwipeyActions(isDragging: $isDragging,
                              emptyLeftSymbolName: emptyVoteSymbolName,
                              shortLeftSymbolName: upvoteSymbolName,
                              shortLeftAction: upvote,
                              shortLeftColor: .upvoteColor,
                              longLeftSymbolName: downvoteSymbolName,
                              longLeftAction: downvote,
                              longLeftColor: .downvoteColor,
                              emptyRightSymbolName: emptySaveSymbolName,
                              shortRightSymbolName: saveSymbolName,
                              shortRightAction: saveComment,
                              shortRightColor: .saveColor,
                              longRightSymbolName: "arrowshape.turn.up.left.fill",
                              longRightAction: replyToComment,
                              longRightColor: .accentColor)
            .border(width: depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[depth % threadingColors.count])
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
    var commentHeader: some View {
        HStack() {
            UserProfileLink(account: account, user: hierarchicalComment.commentView.creator, showServerInstance: shouldShowUserServerInComment, postContext: postContext, commentContext: hierarchicalComment.commentView.comment)
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "clock")
                Text(publishedAgo)
            }
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    var commentBody: some View {
        VStack {
            // comment text or placeholder
            if hierarchicalComment.commentView.comment.deleted {
                Text("Comment was deleted")
                    .italic()
                    .foregroundColor(.secondary)
            }
            else if hierarchicalComment.commentView.comment.removed {
                Text("Comment was removed")
                    .italic()
                    .foregroundColor(.secondary)
            }
            else if !isCollapsed {
                MarkdownView(text: hierarchicalComment.commentView.comment.content)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            
            // embedded post
            if showPostContext {
                EmbeddedPost(account: account, community: hierarchicalComment.commentView.community, post: hierarchicalComment.commentView.post)
            }
        }
    }
    
    @ViewBuilder
    var childComments: some View {
        if !isCollapsed {
            // lazy stack because there might be *lots* of these
            LazyVStack(spacing: 0) {
                ForEach(hierarchicalComment.children) { child in
                    CommentItem(account: account, hierarchicalComment: child, postContext: postContext, depth: depth + 1, showPostContext: false, isDragging: $isDragging)
                }
            }
        }
    }
}

