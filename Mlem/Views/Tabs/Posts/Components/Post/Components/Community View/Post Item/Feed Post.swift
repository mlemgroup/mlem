//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

// NOTES
// Since padding varies depending on compact/large view, it is handled *entirely* in those components. No padding should
// appear anywhere in this file.

import CachedAsyncImage
import QuickLook
import SwiftUI

/**
 Displays a single post in the feed
 */
struct FeedPost: View
{
    // MARK: Environment
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    
    // MARK: Parameters
    
    let postView: APIPostView
    let account: SavedAccount
    
    // MARK: State
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    // swipe-to-vote
    @Binding var isDragging: Bool
    
    // in-feed reply
    @State var replyIsPresented: Bool = false
    @State var replyContents: String = ""
    @State var replyIsSending: Bool = false
    
    // MARK: Computed
    // TODO: real-time swipe-to-vote feedback
    //    var emptyVoteSymbolName: String { displayedVote == .upvote ? "minus.square" : "arrow.up.square" }
    //    var upvoteSymbolName: String { displayedVote == .upvote ? "minus.square.fill" : "arrow.up.square.fill" }
    //    var downvoteSymbolName: String { displayedVote == .downvote ? "minus.square.fill" : "arrow.down.square.fill" }
    //    var emptySaveSymbolName: String { displayedSaved ? "bookmark.slash" : "bookmark" }
    //    var saveSymbolName: String { displayedSaved ? "bookmark.slash.fill" : "bookmark.fill" }
    
    var body: some View {
        VStack(spacing: 0) {
            postItem
                .background(Color.systemBackground)
                .contextMenu {
                    Button("Upvote") {
                        Task(priority: .userInitiated) {
                            await upvotePost()
                        }
                    }
                    Button("Downvote") {
                        Task(priority: .userInitiated) {
                            await downvotePost()
                        }
                    }
                    Button("Save") {
                        Task(priority: .userInitiated) {
                            await savePost()
                        }
                    }
                    Button("Reply") {
                        replyToPost()
                    }
                }
                .addSwipeyActions(isDragging: $isDragging,
                                  emptyLeftSymbolName: "arrow.up.square",
                                  shortLeftSymbolName: "arrow.up.square.fill",
                                  shortLeftAction: upvotePost,
                                  shortLeftColor: .upvoteColor,
                                  longLeftSymbolName: "arrow.down.square.fill",
                                  longLeftAction: downvotePost,
                                  longLeftColor: .downvoteColor,
                                  emptyRightSymbolName: "bookmark",
                                  shortRightSymbolName: "bookmark.fill",
                                  shortRightAction: savePost,
                                  shortRightColor: .saveColor,
                                  longRightSymbolName: "arrowshape.turn.up.left.fill",
                                  longRightAction: replyToPost,
                                  longRightColor: .accentColor)
                .alert("Not yet implemented!", isPresented: $replyIsPresented) {
                    Button("I love beta apps", role: .cancel) { }
                }
            
            Divider()
        }
    }
    
    @ViewBuilder
    var postItem: some View {
        if (shouldShowCompactPosts){
            CompactPost(postView: postView, account: account, voteOnPost: voteOnPost, savePost: { _ in await savePost() }, deletePost: deletePost)
        }
        else {
            LargePost(postView: postView, account: account, isExpanded: false, voteOnPost: voteOnPost, savePost: { _ in await savePost() }, deletePost: deletePost)
        }
    }
    
    
    // Reply handlers
    
    func upvotePost() async {
        await voteOnPost(inputOp: .upvote)
    }
    
    func downvotePost() async {
        await voteOnPost(inputOp: .downvote)
    }
    
    func deletePost() async {
        do {
            let _ = try await Mlem.deletePost(postId: postView.post.id, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to delete post!")
        }
    }
    
    func replyToPost() {
        self.replyIsPresented = true
    }
    /**
     Votes on a post
     NOTE: I /hate/ that this is here and threaded down through the view stack, but that's the only way I can get post votes to propagate properly without weird flickering
     */
    func voteOnPost(inputOp: ScoringOperation) async -> Void {
        do {
            let operation = postView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await ratePost(postId: postView.post.id, operation: operation, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to vote!")
        }
    }
    
    func savePost() async -> Void {
        do {
            _ = try await sendSavePostRequest(account: account, postId: postView.post.id, save: !postView.saved, postTracker: postTracker)
        } catch {
            print("failed to save!")
        }
    }
}

