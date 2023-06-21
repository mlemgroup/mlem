//
//  Comment Item.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

struct CommentItem: View {
    // ==== TEMPORARY PENDING BACKEND CHANGES ====
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
    // ==== END TEMPORARY ====
    
    // constants
    let threadingColors = [Color.red, Color.orange, Color.yellow, Color.green, Color.blue, Color.purple]
    let spacing: CGFloat = 8
    let indent: CGFloat = 10
    
    // environment
    @EnvironmentObject var commentTracker: CommentTracker
    @EnvironmentObject var appState: AppState
    
    let account: SavedAccount
    let hierarchicalComment: HierarchicalComment
    let depth: Int
    
    @Binding var isDragging: Bool
    @FocusState var isReplyFieldFocused: Bool
    
    // state
    @State var isCollapsed: Bool = false
    
    // computed
    var publishedAgo: String { getTimeIntervalFromNow(date: hierarchicalComment.commentView.post.published )}
    
    // init needed to get dirty and clean aligned
    init(account: SavedAccount, hierarchicalComment: HierarchicalComment, depth: Int, isDragging: Binding<Bool>, isReplyFieldFocused: FocusState<Bool>) {
        self.account = account
        self.hierarchicalComment = hierarchicalComment
        self.depth = depth
        _isDragging = isDragging
        _isReplyFieldFocused = isReplyFieldFocused
        
        _dirtyVote = State(initialValue: hierarchicalComment.commentView.myVote ?? .resetVote)
        _dirtyScore = State(initialValue: hierarchicalComment.commentView.counts.score)
        _dirtySaved = State(initialValue: hierarchicalComment.commentView.saved)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                VStack(spacing: spacing) {
                    commentHeader
                    
                    commentBody
                    
                    CommentInteractionBar(commentView: hierarchicalComment.commentView,
                                          account: account,
                                          displayedScore: displayedScore,
                                          displayedVote: displayedVote,
                                          displayedSaved: displayedSaved,
                                          upvote: upvote,
                                          downvote: downvote,
                                          saveComment: saveComment)
                }
                .padding(spacing)
                // CLASSIC SWIPEY
//                .border(width: depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[depth % threadingColors.count])
            }
            .contentShape(Rectangle()) // allow taps in blank space to register
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 1, blendDuration: 0.4)) {
                    isCollapsed.toggle()
                }
            }
            .contextMenu {
                Button("hit me!") {
                    print("hit")
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
            // HIDEY SWIPEY
            .border(width: depth == 0 ? 0 : 2, edges: [.leading], color: threadingColors[depth % threadingColors.count])
            Divider()
            
            childComments
                .transition(.move(edge: .top).combined(with: .opacity))
        }
        // CLASSIC SWIPEY
//        .mask(Rectangle() // clips top to make animation nice but allows swiping to the left
//            .frame(width: 10000)
//            .edgesIgnoringSafeArea(.leading))
        // HIDEY SWIPEY
        .clipped()
        .padding(.leading, depth == 0 ? 0 : indent)
        .transition(.move(edge: .top).combined(with: .opacity))
        .alert("Not yet implemented!", isPresented: $isShowingAlert) {
            Button("I love beta apps", role: .cancel) { }
        }
    }
    
    @ViewBuilder
    var commentHeader: some View {
        HStack() {
            UserProfileLink(account: account, user: hierarchicalComment.commentView.creator)
            
            Spacer()
            
            HStack(spacing: 2) {
                Image(systemName: "clock")
                Text(publishedAgo)
            }
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
    
//    private func upvote() async {
//        try? await rate(hierarchicalComment, operation: .upvote)
//    }
//
//    private func downvote() async {
//        try? await rate(hierarchicalComment, operation: .downvote)
//    }
    
    @ViewBuilder
    var commentBody: some View {
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
                // .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    @ViewBuilder
    var childComments: some View {
        if !isCollapsed {
            // lazy stack because there might be *lots* of these
            LazyVStack(spacing: 0) {
                ForEach(hierarchicalComment.children) { child in
                    CommentItem(account: account, hierarchicalComment: child, depth: depth + 1, isDragging: $isDragging, isReplyFieldFocused: _isReplyFieldFocused)
                }
            }
        }
    }
}

