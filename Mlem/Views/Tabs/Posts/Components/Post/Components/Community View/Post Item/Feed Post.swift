//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

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
    let post: APIPostView
    let account: SavedAccount
    
    @Binding var feedType: FeedType
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
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
                    if let postUrl: URL = URL(string: post.post.apId) {
                        ShareButton(urlToShare: postUrl, isShowingButtonText: true, customText: "Share Post...")
                    }
                    if let postContentUrl = post.post.url {
                        let customText = postContentUrl.isImage ? "Share Image..." : postContentUrl.isFileURL ? "Share File..." : "Share Link..."
                        ShareButton(urlToShare: postContentUrl, isShowingButtonText: true, customText: customText)
                    }
                }

            Divider()
        }.if (!shouldShowCompactPosts) { viewProxy in
            viewProxy.padding(.top)
        }
            .background(Color.systemBackground)
    }
    
    @ViewBuilder
    var postItem: some View {
        if (shouldShowCompactPosts){
            CompactPost(post: post, account: account, voteOnPost: voteOnPost)
        }
        else {
            LargePost(post: post, account: account, isExpanded: false, voteOnPost: voteOnPost)
        }
    }
    
    /**
     Votes on a post
     NOTE: I /hate/ that this is here and threaded down through the view stack, but that's the only way I can get post votes to propagate properly without weird flickering
     */
    func voteOnPost(inputOp: ScoringOperation) async -> Void {
        do {
            let operation = post.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await ratePost(postId: post.id, operation: operation, account: account, postTracker: postTracker, appState: appState)
        } catch {
            print("failed to vote!")
        }
    }
}

