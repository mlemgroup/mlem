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
        VStack(spacing: 0) {
            postItem
                .contextMenu {
                    // general-purpose button template for adding more stuff--also nice for debugging :)
//                        Button {
//                            print(post)
//                        } label: {
//                            Label("Do things", systemImage: "heart")
//                        }
                    
                    // only display share if URL is valid
                    if let postUrl: URL = URL(string: postView.post.apId) {
                        ShareButton(urlToShare: postUrl, isShowingButtonText: true)
                    }
                }

            Divider()
        }.if (!shouldShowCompactPosts) { viewProxy in
            viewProxy.padding(.top)
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
        Text("I'm not ready yet! Come back in a later build :)")
    }
    
    @ViewBuilder
    var replySheetBodyWip: some View {
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
