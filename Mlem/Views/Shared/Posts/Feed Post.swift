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
    
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    @AppStorage("reakMarkStyle") var readMarkStyle: ReadMarkStyle = .bar
    @AppStorage("readBarThickness") var readBarThickness: Int = 3
    
    @AppStorage("upvoteOnSave") var upvoteOnSave: Bool = false

    @EnvironmentObject var postTracker: StandardPostTracker
    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // MARK: Parameters

    @ObservedObject var postModel: PostModel
    let community: CommunityModel?
    let showPostCreator: Bool
    let showCommunity: Bool
    let enableSwipeActions: Bool
    
    init(
        post: PostModel,
        community: CommunityModel? = nil,
        showPostCreator: Bool = true,
        showCommunity: Bool = true,
        enableSwipeActions: Bool = true
    ) {
        self.postModel = post
        self.community = community
        self.showPostCreator = showPostCreator
        self.showCommunity = showCommunity
        self.enableSwipeActions = enableSwipeActions
    }

    // MARK: State

    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    @State private var isComposingReport: Bool = false
    
    // MARK: Destructive confirmation
    
    @State private var isPresentingConfirmDestructive: Bool = false
    @State private var confirmationMenuFunction: StandardMenuFunction?
    
    func confirmDestructive(destructiveFunction: StandardMenuFunction) {
        confirmationMenuFunction = destructiveFunction
        isPresentingConfirmDestructive = true
    }
    
    // MARK: Computed
    
    var barThickness: CGFloat { !postModel.read && diffWithoutColor && readMarkStyle == .bar ? CGFloat(readBarThickness) : .zero }
    var showCheck: Bool { postModel.read && diffWithoutColor && readMarkStyle == .check }

    var body: some View {
        // this allows post deletion to not require tracker updates
        if postModel.post.deleted {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                postItem
                    .border(width: barThickness, edges: [.leading], color: .secondary)
                    .background(Color.systemBackground)
                    //                .background(horizontalSizeClass == .regular ? Color.secondarySystemBackground : Color.systemBackground)
                    //                .clipShape(RoundedRectangle(cornerRadius: horizontalSizeClass == .regular ? 16 : 0))
                    //                .padding(.all, horizontalSizeClass == .regular ? nil : 0)
                    .destructiveConfirmation(
                        isPresentingConfirmDestructive: $isPresentingConfirmDestructive,
                        confirmationMenuFunction: confirmationMenuFunction
                    )
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
                    .contextMenu {
                        ForEach(genMenuFunctions()) { item in
                            MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
                        }
                    }
            }
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
                post: postModel,
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
                            community: postModel.community,
                            serverInstanceLocation: communityServerInstanceLocation
                        )

                        Spacer()

                        if showCheck {
                            ReadCheck()
                        }
                        
                        EllipsisMenu(size: 24, menuFunctions: genMenuFunctions())
                    }

                    if postSize == .headline {
                        HeadlinePost(post: postModel)
                    } else {
                        LargePost(
                            post: postModel,
                            layoutMode: .constant(.preferredSize)
                        )
                    }

                    // posting user
                    if showPostCreator {
                        UserLinkView(
                            user: postModel.creator,
                            serverInstanceLocation: userServerInstanceLocation,
                            communityContext: community
                        )
                    }
                }
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                InteractionBarView(
                    votes: postModel.votes,
                    published: postModel.published,
                    updated: postModel.updated,
                    commentCount: postModel.commentCount,
                    unreadCommentCount: postModel.unreadCommentCount,
                    saved: postModel.saved,
                    accessibilityContext: "post",
                    widgets: layoutWidgetTracker.groups.post,
                    upvote: upvotePost,
                    downvote: downvotePost,
                    save: savePost,
                    reply: replyToPost,
                    shareURL: URL(string: postModel.post.apId),
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
        await postModel.delete()
    }

    func blockUser() async {
        // TODO: migrate to personRepository
        do {
            let response = try await apiClient.blockPerson(id: postModel.creator.userId, shouldBlock: true)
            if response.blocked {
                await postTracker.applyFilter(.blockedUser(postModel.creator.userId))
                hapticManager.play(haptic: .violentSuccess, priority: .high)
                await notifier.add(.success("Blocked \(postModel.creator.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(postModel.creator.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }
    
    func blockCommunity() async {
        // TODO: migrate to communityRepository
        do {
            let response = try await apiClient.blockCommunity(id: postModel.community.communityId, shouldBlock: true)
            if response.blocked {
                await postTracker.applyFilter(.blockedCommunity(postModel.community.communityId))
                await notifier.add(.success("Blocked \(postModel.community.name)"))
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block \(postModel.community.name)",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }

    func replyToPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            post: postModel,
            operation: PostOperation.replyToPost
        ))
    }
    
    func editPost() {
        editorTracker.openEditor(with: PostEditorModel(
            post: postModel
        ))
    }

    /// Votes on a post
    /// - Parameter inputOp: The vote operation to perform
    func voteOnPost(inputOp: ScoringOperation) async {
        await postModel.vote(inputOp: inputOp)
    }

    func savePost() async {
        await postModel.toggleSave(upvoteOnSave: upvoteOnSave)
    }
    
    func reportPost() {
        editorTracker.openEditor(with: ConcreteEditorModel(post: postModel, operation: PostOperation.reportPost))
    }

    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()

        // upvote
        let (upvoteText, upvoteImg) = postModel.votes.myVote == .upvote ?
            ("Undo Upvote", Icons.upvoteSquareFill) :
            ("Upvote", Icons.upvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
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
        let (downvoteText, downvoteImg) = postModel.votes.myVote == .downvote ?
            ("Undo Downvote", Icons.downvoteSquareFill) :
            ("Downvote", Icons.downvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
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
        let (saveText, saveImg) = postModel.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction.standardMenuFunction(
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
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            replyToPost()
        })

        if appState.isCurrentAccountId(postModel.creator.userId) {
            // edit
            ret.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit,
                destructiveActionPrompt: nil,
                enabled: true
            ) {
                editPost()
            })
            
            // delete
            ret.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                destructiveActionPrompt: "Are you sure you want to delete this post? This cannot be undone.",
                enabled: !postModel.post.deleted
            ) {
                Task(priority: .userInitiated) {
                    await deletePost()
                }
            })
        }

        // share
        if let url = URL(string: postModel.post.apId) {
            ret.append(MenuFunction.shareMenuFunction(url: url))
        }

        // report
        ret.append(MenuFunction.standardMenuFunction(
            text: "Report Post",
            imageName: Icons.moderationReport,
            destructiveActionPrompt: AppConstants.reportPostPrompt,
            enabled: true
        ) {
            reportPost()
        })

        // block user
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block User",
            imageName: Icons.userBlock,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser()
            }
        })
        
        // block community
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block Community",
            imageName: Icons.hide,
            destructiveActionPrompt: AppConstants.blockCommunityPrompt,
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
        let (emptySymbolName, fullSymbolName) = postModel.votes.myVote == .upvote ?
            (Icons.resetVoteSquare, Icons.resetVoteSquareFill) :
            (Icons.upvoteSquare, Icons.upvoteSquareFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor,
            action: {
                Task {
                    await upvotePost()
                }
            }
        )
    }

    var downvoteSwipeAction: SwipeAction? {
        guard siteInformation.enableDownvotes else { return nil }

        let (emptySymbolName, fullSymbolName) = postModel.votes.myVote == .downvote ?
            (Icons.resetVoteSquare, Icons.resetVoteSquareFill) :
            (Icons.downvoteSquare, Icons.downvoteSquareFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor,
            action: {
                Task {
                    await downvotePost()
                }
            }
        )
    }

    var saveSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = postModel.saved
            ? (Icons.unsave, Icons.unsaveFill)
            : (Icons.save, Icons.saveFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .saveColor,
            action: {
                Task {
                    await savePost()
                }
            }
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
