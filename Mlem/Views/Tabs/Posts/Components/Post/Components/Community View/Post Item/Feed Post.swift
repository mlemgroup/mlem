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
    
    // arguments
    let post: APIPostView
    let account: SavedAccount
    
    @Binding var feedType: FeedType
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // show large or small post view
            if (shouldShowCompactPosts){
                CompactPost(post: post, account: account)
            }
            else {
                LargePost(post: post, account: account, isExpanded: false)
            }
            
            // thicken up the divider a little for large posts
            Divider()
                .if (!shouldShowCompactPosts) { viewProxy in
                    viewProxy.background(.black)
                }
        }.if (!shouldShowCompactPosts) { viewProxy in
            viewProxy.padding(.top)
        }
            .background(Color.systemBackground)
    }
}

