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

import Dependencies
import QuickLook
import SwiftUI

/// Displays a single post in the feed
struct FeedPost: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.siteInformation) var siteInformation
    
    // MARK: Environment

    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool
    
    @AppStorage("postSize") var postSize: PostSize = .large
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = true
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    @AppStorage("reakMarkStyle") var readMarkStyle: ReadMarkStyle = .bar
    @AppStorage("readBarThickness") var readBarThickness: Int = 3

    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var dirtyVote: ScoringOperation = .resetVote
    @State var dirtyScore: Int = 0
    @State var dirtySaved: Bool = false
    @State var dirty: Bool = false
    
    // MARK: Parameters

    let post: PostModel
    let showPostCreator: Bool
    let showCommunity: Bool
    let enableSwipeActions: Bool
    
    init(
        post: PostModel,
        showPostCreator: Bool = true,
        showCommunity: Bool = true,
        enableSwipeActions: Bool = true
    ) {
        self.post = post
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.enableSwipeActions = enableSwipeActions
    }

    // MARK: State

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    @State private var isComposingReport: Bool = false
    
    // MARK: Computed
    
    var barThickness: CGFloat { !post.read && diffWithoutColor && readMarkStyle == .bar ? CGFloat(readBarThickness) : .zero }
    var showCheck: Bool { post.read && diffWithoutColor && readMarkStyle == .check }

    var body: some View {
        VStack(spacing: 0) {
            postItem
                .border(width: barThickness, edges: [.leading], color: .secondary)
                .background(Color.systemBackground)
//                .background(horizontalSizeClass == .regular ? Color.secondarySystemBackground : Color.systemBackground)
//                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 16 : 0))
//                .padding(.all, horizontalSizeClass == .regular ? nil : 0)
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
                    leading: [
                        enableSwipeActions ? upvoteSwipeAction : nil,
                        enableSwipeActions ? downvoteSwipeAction : nil
                    ],
                    trailing: [
                        enableSwipeActions ? saveSwipeAction : nil,
                        enableSwipeActions ? replySwipeAction : nil
                    ]
                )
        }
    }

    var userServerInstanceLocation: ServerInstanceLocation {
        if !shouldShowUserServerInPost {
            return .disabled
        } else {
            return .bottom
        }
    }
    
    var communityServerInstanceLocation: ServerInstanceLocation {
        if !shouldShowCommunityServerInPost {
            return .disabled
        } else {
            return .bottom
        }
    }

    @ViewBuilder
    var postItem: some View {
        if postSize == .compact {
            CompactPost(
                post: post,
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
                        CommunityLinkView(
                            community: post.community,
                            serverInstanceLocation: communityServerInstanceLocation
                        )

                        Spacer()

                        if showCheck {
                            ReadCheck()
                        }
                        
                        EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                    }

                    if postSize == .headline {
                        HeadlinePost(post: post)
                    } else {
                        LargePost(
                            post: post,
                            layoutMode: .constant(.preferredSize)
                        )
                    }

                    // posting user
                    if showPostCreator {
                        UserLinkView(
                            user: postView.creator,
                            serverInstanceLocation: userServerInstanceLocation
                        )
                    }
                }
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                InteractionBarView(
                    votes: post.votes,
                    published: post.published,
                    numReplies: post.numReplies,
                    saved: post.saved,
                    accessibilityContext: "post",
                    widgets: layoutWidgetTracker.groups.post,
                    upvote: upvotePost,
                    downvote: downvotePost,
                    save: savePost,
                    reply: replyToPost,
                    share: {
                        if let url = URL(string: post.post.apId) {
                            showShareSheet(URLtoShare: url)
                        }
                    },
                    shouldShowScore: shouldShowScoreInPostBar,
                    showDownvotesSeparately: showPostDownvotesSeparately,
                    shouldShowTime: shouldShowTimeInPostBar,
                    shouldShowSaved: shouldShowSavedInPostBar,
                    shouldShowReplies: shouldShowRepliesInPostBar
                )
            }
        }
    }

    func upvotePost() async {
        await voteOnPost(inputOp: .upvote)
    }

    func downvotePost() async {
        await voteOnPost(inputOp: .downvote)
    }

    func deletePost() async {
        await postTracker.delete(post: post)
    }

    func blockUser() async {
        // TODO: migrate to personRepository
        do {
            let response = try await apiClient.blockPerson(id: post.creator.id, shouldBlock: true)
            if response.blocked {
                postTracker.removeUserPosts(from: post.creator.id)
                hapticManager.play(haptic: .violentSuccess, priority: .high)
                await notifier.add(.success("Blocked \(post.creator.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(post.creator.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }
    
    func blockCommunity() async {
        // TODO: migrate to communityRepository
        do {
            let response = try await apiClient.blockCommunity(id: post.community.id, shouldBlock: true)
            if response.blocked {
                postTracker.removeCommunityPosts(from: post.community.id)
                await notifier.add(.success("Blocked \(post.community.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(post.community.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }

    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: post,
            operation: PostOperation.replyToPost
        ))
    }
    
    func editPost() {
        editorTracker.openEditor(with: PostEditorModel(
            community: post.community,
            postTracker: postTracker,
            editPost: post
        ))
    }

    /// Votes on a post
    /// - Parameter inputOp: The vote operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        await postTracker.voteOnPost(post: post, inputOp: inputOp)
    }

    func savePost() async {
        await postTracker.toggleSave(post: post)
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(post: post, operation: PostOperation.reportPost))
    }

    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()

        // upvote
        let (upvoteText, upvoteImg) = post.votes.myVote == .upvote ?
            ("Undo upvote", "arrow.up.square.fill") :
            ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await upvotePost()
            }
        })

        // downvote
        let (downvoteText, downvoteImg) = post.votes.myVote == .downvote ?
            ("Undo downvote", "arrow.down.square.fill") :
            ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await downvotePost()
            }
        })

        // save
        let (saveText, saveImg) = post.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await savePost()
            }
        })

        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            replyToPost()
        })

        if post.creator.id == appState.currentActiveAccount.id {
            // edit
            ret.append(MenuFunction(
                text: "Edit",
                imageName: "pencil",
                destructiveActionPrompt: nil,
                enabled: true
            ) {
                editPost()
            })
            
            // delete
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this post?  This cannot be undone.",
                enabled: !post.post.deleted
            ) {
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
            enabled: true
        ) {
            if let url = URL(string: post.post.apId) {
                showShareSheet(URLtoShare: url)
            }
        })

        // report
        ret.append(MenuFunction(
            text: "Report Post",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: AppConstants.reportPostPrompt,
            enabled: true
        ) {
            reportPost()
        })

        // block user
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser()
            }
        })
        
        // block community
        ret.append(MenuFunction(
            text: "Block Community",
            imageName: AppConstants.blockSymbolName,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockCommunity()
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
        let (emptySymbolName, fullSymbolName) = post.votes.myVote == .upvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyUpvoteSymbolName, AppConstants.fullUpvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor,
            action: upvotePost
        )
    }

    var downvoteSwipeAction: SwipeAction? {
        guard siteInformation.enableDownvotes else { return nil }

        let (emptySymbolName, fullSymbolName) = post.votes.myVote == .downvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyDownvoteSymbolName, AppConstants.fullDownvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor,
            action: downvotePost
        )
    }

    var saveSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = post.saved
            ? (AppConstants.emptyUndoSaveSymbolName, AppConstants.fullUndoSaveSymbolName)
            : (AppConstants.emptySaveSymbolName, AppConstants.fullSaveSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .saveColor,
            action: savePost
        )
    }

    var replySwipeAction: SwipeAction? {
        SwipeAction(
            symbol: .init(emptyName: "arrowshape.turn.up.left", fillName: "arrowshape.turn.up.left.fill"),
            color: .accentColor,
            action: replyToPost
        )
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
