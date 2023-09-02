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

/**
 Displays a single post in the feed
 */
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

    let postView: APIPostView
    let showPostCreator: Bool
    let showCommunity: Bool
    let enableSwipeActions: Bool

    init(
        postView: APIPostView,
        showPostCreator: Bool = true,
        showCommunity: Bool = true,
        enableSwipeActions: Bool = true
    ) {
        self.postView = postView
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.enableSwipeActions = enableSwipeActions
    }

    var displayedVote: ScoringOperation { dirty ? dirtyVote : postView.myVote ?? .resetVote }
    var displayedScore: Int { dirty ? dirtyScore : postView.counts.score }
    var displayedSaved: Bool { dirty ? dirtySaved : postView.saved }

    // MARK: State

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    @State private var isComposingReport: Bool = false
    
    // MARK: Computed
    
    var barThickness: CGFloat { !postView.read && diffWithoutColor && readMarkStyle == .bar ? CGFloat(readBarThickness) : .zero }
    var showCheck: Bool { postView.read && diffWithoutColor && readMarkStyle == .check }

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
                        CommunityLinkView(
                            community: postView.community,
                            serverInstanceLocation: communityServerInstanceLocation
                        )

                        Spacer()

                        if showCheck {
                            ReadCheck()
                        }
                        
                        EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                    }

                    if postSize == .headline {
                        HeadlinePost(postView: postView)
                    } else {
                        LargePost(
                            postView: postView,
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
                    apiView: postView,
                    accessibilityContext: "post",
                    widgets: layoutWidgetTracker.groups.post,
                    displayedScore: displayedScore,
                    displayedVote: displayedVote,
                    displayedSaved: displayedSaved,
                    upvote: upvotePost,
                    downvote: downvotePost,
                    save: savePost,
                    reply: replyToPost,
                    share: {
                        if let url = URL(string: postView.post.apId) {
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
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake downvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore - 1
            case .resetVote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 1
            case .downvote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 2
            }
            dirty = true

            // wait for vote
            await voteOnPost(inputOp: .upvote)

            // unfake downvote
            dirty = false
            return
        }
    }

    func downvotePost() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake upvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 2
            case .resetVote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 1
            case .downvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore + 1
            }
            dirty = true

            // wait for vote
            await voteOnPost(inputOp: .downvote)

            // unfake upvote
            dirty = false
            return
        }
    }

    func deletePost() async {
        do {
            let response = try await apiClient.deletePost(id: postView.post.id, shouldDelete: true)
            hapticManager.play(haptic: .destructiveSuccess, priority: .high)
            postTracker.update(with: response)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }

    func blockUser() async {
        do {
            let response = try await apiClient.blockPerson(id: postView.creator.id, shouldBlock: true)
            if response.blocked {
                postTracker.removeUserPosts(from: postView.creator.id)
                hapticManager.play(haptic: .violentSuccess, priority: .high)
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
    
    func blockCommunity() async {
        do {
            let response = try await apiClient.blockCommunity(id: postView.community.id, shouldBlock: true)
            if response.blocked {
                postTracker.removeCommunityPosts(from: postView.community.id)
                await notifier.add(.success("Blocked \(postView.community.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(postView.community.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }

    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: postView,
            operation: PostOperation.replyToPost
        ))
    }
    
    func editPost() {
        editorTracker.openEditor(with: PostEditorModel(
            community: postView.community,
            postTracker: postTracker,
            editPost: postView.post
        ))
    }

    /// Votes on a post
    /// - Parameter inputOp: The vote operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        do {
            hapticManager.play(haptic: .gentleSuccess, priority: .low)
            let operation = postView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            let updatedPost = try await apiClient.ratePost(id: postView.post.id, score: operation)
            postTracker.update(with: updatedPost)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }

    func savePost() async {
        guard dirty else {
            // fake save
            dirtySaved.toggle()
            dirty = true
            hapticManager.play(haptic: .success, priority: .high)
            
            do {
                let updatedPost = try await apiClient.savePost(id: postView.post.id, shouldSave: dirtySaved)
                postTracker.update(with: updatedPost)
            } catch {
                hapticManager.play(haptic: .failure, priority: .high)
                errorHandler.handle(error)
            }
            dirty = false
            return
        }
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(post: postView, operation: PostOperation.reportPost))
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
            enabled: true
        ) {
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
            enabled: true
        ) {
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

        if postView.creator.id == appState.currentActiveAccount.id {
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
                enabled: !postView.post.deleted
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
            if let url = URL(string: postView.post.apId) {
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
        guard siteInformation.enableDownvotes else { return nil }

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
        SwipeAction(
            symbol: .init(emptyName: "arrowshape.turn.up.left", fillName: "arrowshape.turn.up.left.fill"),
            color: .accentColor,
            action: replyToPost
        )
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
