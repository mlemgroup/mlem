//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import CachedAsyncImage
import QuickLook
import SwiftUI

struct PostItem: View
{
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    
    @State var postTracker: PostTracker
    // @EnvironmentObject var postTracker: PostTracker

    @State var post: APIPostView

    @State var isExpanded: Bool
    
    @State var isInSpecificCommunity: Bool
    
    @State var account: SavedAccount
    
    @Binding var feedType: FeedType
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    // @State var isPostCollapsed: Bool = false
    
    // let iconToTextSpacing: CGFloat = 2
    
    // MARK interaction callbacks
    
    // TODO: extract these to a common location
    func upvotePost() async -> Bool {
        do {
            switch post.myVote
            {
            case .upvoted:
                try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker, appState: appState)
            case .downvoted:
                try await ratePost(post: post, operation: .upvote, account: account, postTracker: postTracker, appState: appState)
            case .none:
                try await ratePost(post: post, operation: .upvote, account: account, postTracker: postTracker, appState: appState)
            }
        } catch {
            return false
        }
        return true
    }
    
    func downvotePost() async -> Bool {
        do {
            switch post.myVote
            {
            case .upvoted:
                try await ratePost(post: post, operation: .downvote, account: account, postTracker: postTracker, appState: appState)
            case .downvoted:
                try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker, appState: appState)
            case .none:
                try await ratePost(post: post, operation: .downvote, account: account, postTracker: postTracker, appState: appState)
            }
        } catch {
            return false
        }
        
        return true
    }
    
    func savePost() async -> Bool {
        do {
#warning("TODO: Make this actually save a post")
        } catch {
            return false
        }
        return true
    }
    
    // TODO: move this to user settings
    let compact = false
    
    var body: some View {
        NavigationLink(destination: PostExpanded(account: account, postTracker: postTracker, post: post, feedType: $feedType)) {
            VStack(spacing: 0) {
                // show large or small post view
                if (shouldShowCompactPosts){
                    CompactPost(postTracker: postTracker, post: post, account: account)
                }
                else {
                    LargePost(postTracker: postTracker, account: account, post: post, isExpanded: false)
                }
                
                // divider--thicken it up a little for large posts
                Divider()
                    .if (!shouldShowCompactPosts) { viewProxy in
                        viewProxy.background(.black)
                    }
            }.if(!shouldShowCompactPosts) { viewProxy in
                viewProxy.padding(.top)
            }
                .background(Color.systemBackground)
        }
        .buttonStyle(EmptyButtonStyle())
    }
}

