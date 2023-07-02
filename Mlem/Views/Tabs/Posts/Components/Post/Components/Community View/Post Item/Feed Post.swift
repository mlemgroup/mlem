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
struct FeedPost: View {
    // MARK: Environment
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false

    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState

    // MARK: Parameters

    let postView: APIPostView
    let account: SavedAccount
    let showPostCreator: Bool
    let showCommunity: Bool

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
                    ForEach(genMenuFunctions()) { item in
                        Button {
                            item.callback()
                        } label: {
                            Label(item.text, systemImage: item.imageName)
                        }
                    }
                }
                .addSwipeyActions(isDragging: $isDragging,
                                  emptyLeftSymbolName: "arrow.up.square",
                                  shortLeftSymbolName: "arrow.up.square.fill",
                                  shortLeftAction: upvotePost,
                                  shortLeftColor: .upvoteColor,
                                  longLeftSymbolName: appState.enableDownvote ? "arrow.down.square.fill" : nil,
                                  longLeftAction: appState.enableDownvote ? downvotePost : nil,
                                  longLeftColor: appState.enableDownvote ? .downvoteColor : nil,
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
        VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
            // community name
            if showCommunity {
                CommunityLinkView(community: postView.community)
            }
            
            if shouldShowCompactPosts {
                CompactPost(
                    postView: postView,
                    account: account
                )
            } else {
                LargePost(
                    postView: postView,
                    account: account,
                    isExpanded: false
                )
            }
            
            // posting user
            if showPostCreator {
                UserProfileLink(account: account, user: postView.creator, showServerInstance: true)
            }
  
            PostInteractionBar(postView: postView,
                               account: account,
                               menuFunctions: genMenuFunctions(),
                               voteOnPost: voteOnPost,
                               updatedSavePost: { _ in await savePost() },
                               deletePost: deletePost)
        }
        .padding(AppConstants.postAndCommentSpacing)
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
            _ = try await Mlem.deletePost(postId: postView.post.id, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to delete post: \(error)")
        }
    }
    
    func replyToPost() {
        self.replyIsPresented = true
    }

    /// Votes on a post
    /// - Parameter inputOp: The vote operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            let operation = postView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            _ = try await ratePost(
                postId: postView.post.id,
                operation: operation,
                account: account,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            print("failed to vote!")
        }
    }

    func savePost() async {
        do {
            _ = try await sendSavePostRequest(account: account, postId: postView.post.id, save: !postView.saved, postTracker: postTracker)
        } catch {
            print("failed to save!")
        }
    }
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = postView.myVote == .upvote ?
        ("Undo upvote", "arrow.up.square.fill") :
        ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await upvotePost()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = postView.myVote == .downvote ?
        ("Undo downvote", "arrow.down.square.fill") :
        ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await downvotePost()
            }
        })
        
        // save
        let (saveText, saveImg) = postView.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await savePost()
            }
        })
        
        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true) {
            replyToPost()
        })
        
        // delete
        if postView.creator.id == account.id {
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this post?  This cannot be undone.",
                enabled: !postView.post.deleted) {
                Task(priority: .userInitiated) {
                    await deletePost()
                }
            })
        }
        
        // share
        ret.append(MenuFunction(
            text: "Share",
            imageName: "square.and.arrow.up",
            destructiveActionPrompt: nil,
            enabled: true) {
            if let url = URL(string: postView.post.apId) {
                showShareSheet(URLtoShare: url)
            }
        })
        
        return ret
    }
    // swiftlint:enable function_body_length
}
