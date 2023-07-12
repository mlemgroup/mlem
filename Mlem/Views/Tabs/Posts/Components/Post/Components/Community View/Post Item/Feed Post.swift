//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

// NOTES
// Since padding varies depending on compact/large view, it is handled *entirely* in those components. No padding should
// appear anywhere in this file.

// swiftlint:disable file_length
// swiftlint:disable type_body_length

import CachedAsyncImage
import QuickLook
import SwiftUI
import AlertToast

/**
 Displays a single post in the feed
 */
struct FeedPost: View {
    // MARK: Environment
    @AppStorage("postSize") var postSize: PostSize = .headline
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    // MARK: Parameters
    
    init(postView: APIPostView,
         showPostCreator: Bool = true,
         showCommunity: Bool = true,
         showInteractionBar: Bool = true,
         enableSwipeActions: Bool = true,
         isDragging: Binding<Bool>,
         replyToPost: ((APIPostView) -> Void)?) {
        self.postView = postView
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.showInteractionBar = showInteractionBar
        self.enableSwipeActions = enableSwipeActions
        self.replyToPost = replyToPost
        self._isDragging = isDragging
    }
    
    let postView: APIPostView
    let showPostCreator: Bool
    let showCommunity: Bool
    let showInteractionBar: Bool
    let enableSwipeActions: Bool
    let replyToPost: ((APIPostView) -> Void)?

    // MARK: State

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    @State private var isComposingReport: Bool = false

    // swipe-to-vote
    @Binding var isDragging: Bool
    
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
                .addSwipeyActions(
                    isDragging: $isDragging,
                    primaryLeadingAction: enableSwipeActions ? upvoteSwipeAction : nil,
                    secondaryLeadingAction: enableSwipeActions ? downvoteSwipeAction : nil,
                    primaryTrailingAction: enableSwipeActions ? saveSwipeAction : nil,
                    secondaryTrailingAction: enableSwipeActions ? replySwipeAction : nil
                )
        }
        .sheet(isPresented: $isComposingReport) {
            ReportComposerView(reportedPost: postView)
        }
    }
    
    private func calculateServerInstanceLocation() -> ServerInstanceLocation {
        guard shouldShowUserServerInPost else {
            return .disabled
        }
        if postSize == .compact {
            return .trailing
        } else {
            return .bottom
        }
    }

    @ViewBuilder
    var postItem: some View {
        
        if postSize == .compact {
            UltraCompactPost(
                postView: postView,
                showCommunity: showCommunity,
                menuFunctions: genMenuFunctions()
            )
        } else {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                    // community name
                    // TEMPORARILY DISABLED: conditionally showing based on community
                    // if showCommunity {
                    //    CommunityLinkView(community: postView.community)
                    // }
                    HStack {
                        CommunityLinkView(community: postView.community)
                        
                        Spacer()
                        
                        EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                    }
                    
                    if postSize == .headline {
                        HeadlinePost(postView: postView)
                    } else {
                        LargePost(
                            postView: postView,
                            isExpanded: false
                        )
                    }
                    
                    // posting user
                    if showPostCreator {
                        UserProfileLink(user: postView.creator, serverInstanceLocation: .bottom)
                    }
                }
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                if showInteractionBar {
                    PostInteractionBar(postView: postView,
                                       menuFunctions: genMenuFunctions(),
                                       voteOnPost: voteOnPost,
                                       updatedSavePost: { _ in await savePost() },
                                       deletePost: deletePost,
                                       replyToPost: replyToThisPost)
                }
            }
            .background(Color.systemBackground)
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
            _ = try await Mlem.deletePost(
                postId: postView.post.id,
                account: appState.currentActiveAccount,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    func blockUser() async {
        do {
            let blocked = try await blockPerson(
                account: appState.currentActiveAccount,
                person: postView.creator,
                blocked: true
            )
            if blocked {
                postTracker.removePosts(from: postView.creator.id)
                
                let toast = AlertToast(
                    displayMode: .alert,
                    type: .complete(.blue),
                    title: "Blocked \(postView.creator.name)"
                )
                appState.toast = toast
                appState.isShowingToast = true
            } // Show Toast
        } catch {
            let toast = AlertToast(
                displayMode: .alert,
                type: .error(.red),
                title: "Unable to block \(postView.creator.name)"
            )
            appState.toast = toast
            appState.isShowingToast = true
        }
    }
    
    func replyToThisPost() {
        if let replyCallback = replyToPost {
            replyCallback(postView)
        }
    }

    /// Votes on a post
    /// - Parameter inputOp: The vote operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            let operation = postView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            _ = try await ratePost(
                postId: postView.post.id,
                operation: operation,
                account: appState.currentActiveAccount,
                postTracker: postTracker,
                appState: appState
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }

    func savePost() async {
        do {
            _ = try await sendSavePostRequest(
                account: appState.currentActiveAccount,
                postId: postView.post.id,
                save: !postView.saved,
                postTracker: postTracker
            )
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
    }
    
    func replyToPostWrapper() async {
        if let replyToPostCallback = replyToPost {
            replyToPostCallback(postView)
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
        if let replyCallback = replyToPost {
            ret.append(MenuFunction(
                text: "Reply",
                imageName: "arrowshape.turn.up.left",
                destructiveActionPrompt: nil,
                enabled: true) {
                    replyCallback(postView)
                })
        }
        
        // delete
        if postView.creator.id == appState.currentActiveAccount.id {
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
        
        // report
        ret.append(MenuFunction(
            text: "Report",
            imageName: "exclamationmark.shield",
            destructiveActionPrompt: nil,
            enabled: true) {
                isComposingReport = true
            })
        
        // block user
        ret.append(MenuFunction(
            text: "Block User",
            imageName: "person.fill.xmark",
            destructiveActionPrompt: nil,
            enabled: true) {
                Task(priority: .userInitiated) {
                    await blockUser()
                }
            })
        
        return ret
    }
    // swiftlint:enable function_body_length
}

// MARK: - Swipe Actions

extension FeedPost {

    // TODO: if we want to mirror the behaviour in comments here we need the `dirty` operation to be visible from this
    // context, which at present would require some work as it occurs down inside the post interaction bar
    // this may need to wait until we complete https://github.com/mormaer/Mlem/issues/117
    
//    private var emptyVoteSymbolName: String { displayedVote == .upvote ? "minus.square" : "arrow.up.square" }
//    private var upvoteSymbolName: String { displayedVote == .upvote ? "minus.square.fill" : "arrow.up.square.fill" }
//    private var downvoteSymbolName: String { displayedVote == .downvote ? "minus.square.fill" : "arrow.down.square.fill" }
//    private var emptySaveSymbolName: String { displayedSaved ? "bookmark.slash" : "bookmark" }
//    private var saveSymbolName: String { displayedSaved ? "bookmark.slash.fill" : "bookmark.fill" }
    
    var upvoteSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = postView.myVote == .upvote ?
        (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
        (AppConstants.emptyUpvoteSymbolName, AppConstants.fullUpvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor,
            action: upvotePost
        )
    }
    
    var downvoteSwipeAction: SwipeAction? {
        guard appState.enableDownvote else { return nil }
        
        let (emptySymbolName, fullSymbolName) = postView.myVote == .downvote ?
        (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
        (AppConstants.emptyDownvoteSymbolName, AppConstants.fullDownvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor,
            action: downvotePost
        )
    }
    
    var saveSwipeAction: SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: "bookmark", fillName: "bookmark.fill"),
            color: .saveColor,
            action: savePost
        )
    }
    
    var replySwipeAction: SwipeAction? {
        if replyToPost != nil {
            return SwipeAction(
                symbol: .init(emptyName: "arrowshape.turn.up.left", fillName: "arrowshape.turn.up.left.fill"),
                color: .accentColor,
                action: replyToPostWrapper
            )
        } else {
            return nil
        }
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
