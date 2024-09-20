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
    
    @State private var menuFunctionPopup: MenuFunctionPopup?
    
    var isMod: Bool {
        siteInformation.isModOrAdmin(communityId: postModel.community.communityId)
    }
    
    var combinedMenuFunctions: [MenuFunction] {
        postModel.combinedMenuFunctions(
            editorTracker: editorTracker,
            showSelectText: postSize == .large,
            postTracker: postTracker,
            community: isMod ? postModel.community : nil,
            modToolTracker: isMod ? modToolTracker : nil
        )
    }
    
    // MARK: Computed
    
    var barThickness: CGFloat { !postModel.read && diffWithoutColor && readMarkStyle == .bar ? CGFloat(readBarThickness) : .zero }
    var showCheck: Bool { postModel.read && diffWithoutColor && readMarkStyle == .check }

    var body: some View {
        // this allows post deletion/removal to not require tracker updates
        if postModel.post.deleted || (postModel.post.removed && !isMod) || postModel.purged {
            EmptyView()
        } else {
            VStack(spacing: 0) {
                postItem
                    .border(width: barThickness, edges: [.leading], color: .secondary)
                    .background(Color.systemBackground)
                    .destructiveConfirmation(menuFunctionPopup: $menuFunctionPopup)
                    .id(postModel.uid)
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
                        ForEach(combinedMenuFunctions) { item in
                            MenuButton(menuFunction: item, menuFunctionPopup: $menuFunctionPopup)
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
    
    /// Render read pinned posts in less "in-your-face" way.
    private var renderPinnedAsCompact: Bool {
        /// Only render pinned posts in compact size in Community feed, ignore this behaviour in other feed types (e.g. Aggregate). [2024.01]
        guard case .community = postTracker?.feedType else {
            return false
        }
        return postModel.read && (postModel.post.featuredLocal || postModel.post.featuredCommunity)
    }
    
    @ViewBuilder
    private var compactPost: some View {
        CompactPost(
            post: postModel,
            postTracker: postTracker,
            showCommunity: showCommunity
        )
    }

    @ViewBuilder
    var postItem: some View {
        if postSize == .compact || renderPinnedAsCompact {
            compactPost
        } else {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                    HStack {
                        CommunityLinkView(
                            community: postModel.community,
                            serverInstanceLocation: communityServerInstanceLocation
                        )
                        Spacer()
                        if showCheck {
                            ReadCheck()
                        }
                        PostEllipsisMenus(postModel: postModel, postTracker: postTracker)
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
                .padding(.top, AppConstants.standardSpacing)
                .padding(.horizontal, AppConstants.standardSpacing)
                
                InteractionBarView(context: .post, widgets: enrichLayoutWidgets())
            }
        }
    }
    
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.post.compactMap { baseWidget in
            switch baseWidget {
            case .infoStack:
                .infoStack(
                    colorizeVotes: false,
                    votes: postModel.votes,
                    published: postModel.published,
                    updated: postModel.updated,
                    commentCount: postModel.commentCount,
                    unreadCommentCount: postModel.unreadCommentCount,
                    saved: postModel.saved
                )
            case .upvote:
                .upvote(myVote: postModel.votes.myVote, upvote: postModel.toggleUpvote)
            case .downvote:
                .downvote(myVote: postModel.votes.myVote, downvote: postModel.toggleDownvote)
            case .save:
                .save(saved: postModel.saved, save: postModel.toggleSave)
            case .reply:
                .reply(reply: replyToPost)
            case .share:
                .share(shareUrl: postModel.post.apId)
            case .upvoteCounter:
                .upvoteCounter(votes: postModel.votes, upvote: postModel.toggleUpvote)
            case .downvoteCounter:
                .downvoteCounter(votes: postModel.votes, downvote: postModel.toggleDownvote)
            case .scoreCounter:
                .scoreCounter(votes: postModel.votes, upvote: postModel.toggleUpvote, downvote: postModel.toggleDownvote)
            default:
                nil
            }
        }
    }
}

// MARK: - Swipe Actions

extension FeedPost {
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
