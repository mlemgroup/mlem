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
    @State var rightSwipeSymbol: String = "arrowshape.turn.up.left"
    
    // in-feed reply
    @State var replyIsPresented: Bool = false
    @State var replyContents: String = ""
    @State var replyIsSending: Bool = false
   
    
    var body: some View {
            ZStack {
                dragBackground
                HStack(spacing: 0) {
                    Image(systemName: leftSwipeSymbol)
                        .font(.title)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    Spacer()
                    Image(systemName: rightSwipeSymbol)
                        .font(.title)
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                postItem
                    .background(Color.systemBackground)
                    .offset(x: dragPosition.width)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 15) // min distance prevents conflict with scrolling drag gesture
                            .onChanged {
                                let w = $0.translation.width
                                
                                if w < -1 * AppConstants.longSwipeDragMin {
                                    rightSwipeSymbol = "arrowshape.turn.up.left.fill"
                                    dragBackground = .accentColor
                                    if prevDragPosition >= -1 * AppConstants.longSwipeDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                else if w < -1 * AppConstants.shortSwipeDragMin {
                                    rightSwipeSymbol = "bookmark.fill"
                                    dragBackground = .saveColor
                                    if prevDragPosition >= -1 * AppConstants.shortSwipeDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                else if w < 0 {
                                    rightSwipeSymbol = "bookmark"
                                    dragBackground = .saveColor.opacity(-1 * w / AppConstants.shortSwipeDragMin)
                                }
                                else if w < AppConstants.shortSwipeDragMin {
                                    leftSwipeSymbol = "arrow.up.square"
                                    dragBackground = .upvoteColor.opacity(w / AppConstants.shortSwipeDragMin)
                                }
                                else if w < AppConstants.longSwipeDragMin {
                                    leftSwipeSymbol = "arrow.up.square.fill"
                                    dragBackground = .upvoteColor
                                    if prevDragPosition <= AppConstants.shortSwipeDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                else {
                                    leftSwipeSymbol = "arrow.down.square.fill"
                                    dragBackground = .downvoteColor
                                    if prevDragPosition <= AppConstants.longSwipeDragMin {
                                        AppConstants.hapticManager.notificationOccurred(.success)
                                    }
                                }
                                prevDragPosition = w
                                dragPosition = $0.translation
                            }
                            .onEnded {
                                let w = $0.translation.width
                                // TODO: instant upvote feedback (waiting on backend)
                                if w < -1 * AppConstants.longSwipeDragMin {
                                    replyIsPresented = true
                                }
                                else if w < -1 * AppConstants.shortSwipeDragMin {
                                    Task(priority: .userInitiated) {
                                        await savePost(save: !postView.saved)
                                    }
                                }
                                else if w > AppConstants.longSwipeDragMin {
                                    Task(priority: .userInitiated) {
                                        await voteOnPost(inputOp: .downvote)
                                    }
                                }
                                else if w > AppConstants.shortSwipeDragMin {
                                    Task(priority: .userInitiated) {
                                        await voteOnPost(inputOp: .upvote)
                                    }
                                }
                                withAnimation(.interactiveSpring()) {
                                    dragPosition = .zero
                                    leftSwipeSymbol = "arrow.up"
                                    rightSwipeSymbol = "bookmark"
                                    dragBackground = .systemBackground
                                }
                            }
                    )
            }
            .sheet(isPresented: $replyIsPresented) {
                replySheetBody
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
    
    @ViewBuilder
    var replySheetBody: some View {
        VStack() {
            ZStack {
                Text("Reply")
                    .bold()
                
                HStack {
                    Button("Cancel") {
                        replyIsPresented = false
                        replyContents = ""
                    }
                    Spacer()
                    Button(action: {
                        if (!replyContents.isEmpty) {
                            Task(priority: .userInitiated) {
                                do {
                                    replyIsSending = true
                                    try await postComment(
                                        to: postView,
                                        commentContents: replyContents,
                                        account: account,
                                        appState: appState
                                    )
                                    replyIsPresented = false
                                    replyContents = ""
                                } catch {
                                    print("failed!")
                                }
                                replyIsSending = false
                            }
                        }
                    }) {
                        Image(systemName: replyContents.isEmpty ? "paperplane" : "paperplane.fill")
                    }
                }
                .foregroundColor(.accentColor)
            }
            
            TextField("Reply to post", text: $replyContents, prompt: Text("\(account.username):"), axis: .vertical)
                .presentationDetents([.medium])
            
            Spacer()
        }
        .padding()
        .overlay(replyIsSending ? Color(white: 0, opacity: 0.1) : .clear)
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
    
    func savePost(save: Bool) async -> Void {
        do {
            try await sendSavePostRequest(account: account, postId: postView.id, save: save, postTracker: postTracker)
        } catch {
            print("failed to save!")
        }
    }
}
