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
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    
    @EnvironmentObject var postTracker: PostTracker
    @EnvironmentObject var appState: AppState
    
    // arguments
    let postView: APIPostView
    let account: SavedAccount
    
    @Binding var feedType: FeedType
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    // swipe-to-vote
    @State var dragPosition: CGSize = .zero
    @State var prevDragPosition: CGFloat = .zero
    @State var dragBackground: Color = .systemBackground
    @State var leftSwipeSymbol: String = "arrow.up"
    @State var leftSwipeSymbolColor: Color = .secondary
    
    var body: some View {
            ZStack {
                dragBackground
                HStack(spacing: 0) {
                    Image(systemName: leftSwipeSymbol)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .foregroundColor(leftSwipeSymbolColor)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                postItem
                    .background(Color.systemBackground)
                    .offset(x: dragPosition.width)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 15) // distance prevents conflict with scrolling drag gesture
                            .onChanged {
                                let w = $0.translation.width
                                
                                if w < AppConstants.upvoteDragMin {
                                    leftSwipeSymbol = "arrow.up"
                                    leftSwipeSymbolColor = .secondary
                                    dragBackground = .upvoteColor.opacity(w / AppConstants.upvoteDragMin)
                                }
                                else if w < AppConstants.downvoteDragMin {
                                    leftSwipeSymbol = "arrow.up"
                                    leftSwipeSymbolColor = .white
                                    dragBackground = .upvoteColor
                                    if prevDragPosition <= AppConstants.upvoteDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                else {
                                    leftSwipeSymbol = "arrow.down"
                                    dragBackground = .downvoteColor
                                    if prevDragPosition <= AppConstants.downvoteDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                prevDragPosition = w
                                dragPosition = $0.translation
                            }
                            .onEnded {
                                // TODO: instant upvote feedback (waiting on backend)
                                if $0.translation.width > AppConstants.downvoteDragMin {
                                    Task(priority: .userInitiated) {
                                        await voteOnPost(inputOp: .downvote)
                                    }
                                } else if $0.translation.width > AppConstants.upvoteDragMin {
                                    Task(priority: .userInitiated) {
                                        await voteOnPost(inputOp: .upvote)
                                    }
                                }
                                withAnimation(.interactiveSpring()) {
                                    dragPosition = .zero
                                    leftSwipeSymbol = "arrow.up"
                                    dragBackground = .systemBackground
                                }
                            }
                    )
//                    .contextMenu {
//                        // general-purpose button template for adding more stuff--also nice for debugging :)
//                        // Button {
//                        //     print(post)
//                        // } label: {
//                        //     Label("Do things", systemImage: "heart")
//                        // }
//
//                        // only display share if URL is valid
//                        if let postUrl: URL = URL(string: postView.post.apId) {
//                            ShareButton(urlToShare: postUrl, isShowingButtonText: true)
//                        }
//                    }
            }
        }
    
    @ViewBuilder
    var postItem: some View {
        if (shouldShowCompactPosts){
            CompactPost(postView: postView, account: account, voteOnPost: voteOnPost)
        }
        else {
            LargePost(postView: postView, account: account, isExpanded: false, voteOnPost: voteOnPost)
        }
    }
    
    /**
     Votes on a post
     NOTE: I /hate/ that this is here and threaded down through the view stack, but that's the only way I can get post votes to propagate properly without weird flickering
     */
    func voteOnPost(inputOp: ScoringOperation) async -> Void {
        do {
            let operation = postView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await ratePost(postId: postView.id, operation: operation, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to vote!")
        }
    }
}

