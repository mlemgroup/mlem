//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

// NOTES
// Since padding varies depending on compact/large view, it is handled *entirely* in those components. No padding should
// appear anywhere in this file.

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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.feedType) var feedType
    
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

    @EnvironmentObject var editorTracker: EditorTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    // MARK: Parameters

    @ObservedObject var postModel: PostModel
    var postTracker: StandardPostTracker?
    let community: CommunityModel?
    let showPostCreator: Bool
    let showCommunity: Bool
    let enableSwipeActions: Bool
    
    init(
        post: PostModel,
        postTracker: StandardPostTracker?,
        community: CommunityModel? = nil,
        showPostCreator: Bool = true,
        showCommunity: Bool = true,
        enableSwipeActions: Bool = true
    ) {
        self.postModel = post
        self.postTracker = postTracker
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
                        let functions = postModel.menuFunctions(
                            editorTracker: editorTracker,
                            postTracker: postTracker
                        )
                        ForEach(functions) { item in
                            MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
                        }
                        
                        // TODO: ERIC check if moderator using SiteInformation UserModel mod list
                        if let community, community.isModerator(siteInformation.userId) {
                            Menu("Community Moderation") {
                                ForEach(postModel.modMenuFunctions(community: community, modToolTracker: modToolTracker)) { function in
                                    MenuButton(menuFunction: function, confirmDestructive: confirmDestructive)
                                }
                            }
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
    
    func replyToPost() {
        editorTracker.openEditor(
            with: ConcreteEditorModel(post: postModel, operation: PostOperation.replyToPost)
        )
    }

    @ViewBuilder
    var postItem: some View {
        if postSize == .compact {
            let functions = postModel.menuFunctions(editorTracker: editorTracker, postTracker: postTracker)
            CompactPost(
                post: postModel,
                showCommunity: showCommunity,
                menuFunctions: functions
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
                        
                        let functions = postModel.menuFunctions(
                            editorTracker: editorTracker,
                            postTracker: postTracker
                        )
                        EllipsisMenu(size: 24, menuFunctions: functions)
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
                            bannedFromCommunity: postModel.creatorBannedFromCommunity,
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
                    upvote: postModel.toggleUpvote,
                    downvote: postModel.toggleDownvote,
                    save: postModel.toggleSave,
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
                    await postModel.toggleUpvote()
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
                    await postModel.toggleDownvote()
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
                    await postModel.toggleSave()
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
