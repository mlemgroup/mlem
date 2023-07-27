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
import Dependencies
import SwiftUI
import QuickLook

/**
 Displays a single post in the feed
 */
struct FeedPost: View {
    
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    
    // MARK: Environment
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true

    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var appState: AppState

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: Parameters

    init(postView: APIPostView,
         showPostCreator: Bool = true,
         showCommunity: Bool = true,
         showInteractionBar: Bool = true,
         enableSwipeActions: Bool = true) {
        self.postView = postView
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.showInteractionBar = showInteractionBar
        self.enableSwipeActions = enableSwipeActions
    }

    let postView: APIPostView
    let showPostCreator: Bool
    let showCommunity: Bool
    let showInteractionBar: Bool
    let enableSwipeActions: Bool

    // MARK: State

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    @State private var isComposingReport: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            postItem
                .background(horizontalSizeClass == .regular ? Color.secondarySystemBackground : Color.systemBackground)
                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 16 : 0))
                .padding(.all, horizontalSizeClass == .regular ? nil : 0)
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
                    primaryLeadingAction: enableSwipeActions ? upvoteSwipeAction : nil,
                    secondaryLeadingAction: enableSwipeActions ? downvoteSwipeAction : nil,
                    primaryTrailingAction: enableSwipeActions ? saveSwipeAction : nil,
                    secondaryTrailingAction: enableSwipeActions ? replySwipeAction : nil
                )
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
                                       replyToPost: replyToPost)
                }
            }
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
                await notifier.add(.success("Blocked \(postView.creator.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(postView.creator.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }

    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           post: postView,
                                                           operation: PostOperation.replyToPost))
    }
    
    func editPost() {
        editorTracker.openEditor(with: PostEditorModel(community: postView.community,
                                                       appState: appState,
                                                       postTracker: postTracker,
                                                       editPost: postView.post))
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
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState, post: postView, operation: PostOperation.reportPost))
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

        if postView.creator.id == appState.currentActiveAccount.id {
            // edit
            ret.append(MenuFunction(
                text: "Edit",
                imageName: "pencil",
                destructiveActionPrompt: nil,
                enabled: true) {
                    editPost()
                })
            
            // delete
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
            text: "Report Post",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: nil,
            enabled: true) {
                reportPost()
            })

        // block user
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
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
        let (emptySymbolName, fullSymbolName) = postView.saved
        ? (AppConstants.emptyUndoSaveSymbolName, AppConstants.fullUndoSaveSymbolName)
        : (AppConstants.emptySaveSymbolName, AppConstants.fullSaveSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .saveColor,
            action: savePost
        )
    }

    var replySwipeAction: SwipeAction? {
        return SwipeAction(
            symbol: .init(emptyName: "arrowshape.turn.up.left", fillName: "arrowshape.turn.up.left.fill"),
            color: .accentColor,
            action: replyToPost
        )
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
