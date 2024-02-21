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
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.notifier) var notifier
    @Dependency(\.hapticManager) var hapticManager
    
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

    // @EnvironmentObject var postTracker: StandardPostTracker
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    // MARK: Parameters

    let post: any Post2Providing
    var postTracker: StandardPostTracker?
    let showPostCreator: Bool
    let showCommunity: Bool
    let enableSwipeActions: Bool
    
    init(
        post: any Post2Providing,
        postTracker: StandardPostTracker?,
        showPostCreator: Bool = true,
        showCommunity: Bool = true,
        enableSwipeActions: Bool = true
    ) {
        self.post = post
        self.postTracker = postTracker
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
    
    var barThickness: CGFloat { !post.isRead && diffWithoutColor && readMarkStyle == .bar ? CGFloat(readBarThickness) : .zero }
    var showCheck: Bool { post.isRead && diffWithoutColor && readMarkStyle == .check }

    var body: some View {
        // this allows post deletion to not require tracker updates
        if post.deleted || post.creator.blocked || post.community.blocked {
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
//                    .contextMenu {
//                        let functions = post.menuFunctions(
//                            editorTracker: editorTracker,
//                            postTracker: postTracker
//                        )
//                        ForEach(functions) { item in
//                            MenuButton(menuFunction: item, confirmDestructive: confirmDestructive)
//                        }
//                    }
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
//        editorTracker.openEditor(
//            with: ConcreteEditorModel(post: post, operation: PostOperation.replyToPost)
//        )
    }

    @ViewBuilder
    var postItem: some View {
        if postSize == .compact {
            // let functions = post.menuFunctions(editorTracker: editorTracker, postTracker: postTracker)
            let functions = [MenuFunction]()
            CompactPost(
                post: post,
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
                            community: post.community,
                            serverInstanceLocation: communityServerInstanceLocation
                        )

                        Spacer()

                        if showCheck {
                            ReadCheck()
                        }
//
//                        let functions = post.menuFunctions(
//                            editorTracker: editorTracker,
//                            postTracker: postTracker
//                        )
//                        EllipsisMenu(size: 24, menuFunctions: functions)
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
                        PersonLinkView(
                            person: post.creator,
                            serverInstanceLocation: userServerInstanceLocation,
                            communityContext: post.community
                        )
                    }
                }
                .padding(.top, AppConstants.postAndCommentSpacing)
                .padding(.horizontal, AppConstants.postAndCommentSpacing)
                
                InteractionBarView(
                    content: post,
                    accessibilityContext: "post",
                    widgets: layoutWidgetTracker.groups.post,
                    reply: replyToPost,
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
        let (emptySymbolName, fullSymbolName) = post.myVote == .upvote ?
            (Icons.resetVoteSquare, Icons.resetVoteSquareFill) :
            (Icons.upvoteSquare, Icons.upvoteSquareFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor,
            action: {
//                Task {
//                    await postModel.toggleUpvote()
//                }
            }
        )
    }

    var downvoteSwipeAction: SwipeAction? {
        // guard siteInformation.enableDownvotes else { return nil }

        let (emptySymbolName, fullSymbolName) = post.myVote == .downvote ?
            (Icons.resetVoteSquare, Icons.resetVoteSquareFill) :
            (Icons.downvoteSquare, Icons.downvoteSquareFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor,
            action: {
//                Task {
//                    await postModel.toggleDownvote()
//                }
            }
        )
    }

    var saveSwipeAction: SwipeAction {
        let (emptySymbolName, fullSymbolName) = post.isSaved
            ? (Icons.unsave, Icons.unsaveFill)
            : (Icons.save, Icons.saveFill)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .saveColor,
            action: {
//                Task {
//                    await postModel.toggleSave()
//                }
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
