//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import QuickLook
import SwiftUI
import CachedAsyncImage

struct PostItem: View
{
    @AppStorage("postDisplayType") var postDisplayType: PostDisplayOptions = .fullDisplay
    
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @EnvironmentObject var appState: AppState

    @State var postTracker: PostTracker
    
    let post: Post

    @State var isExpanded: Bool
    
    @State var isInSpecificCommunity: Bool
    
    @State var account: SavedAccount
    
    @Binding var feedType: FeedType
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    @State var isPostCollapsed: Bool = false

    let iconToTextSpacing: CGFloat = 2

    var body: some View
    {
        VStack(alignment: .leading)
        {
            VStack(alignment: .leading, spacing: 15)
            {
                HStack(alignment: .top)
                {
                    if !isExpanded
                    { // Show this when the post is just in the list and not expanded
                        VStack(alignment: .leading, spacing: 8)
                        {
                            HStack
                            {
                                if !isInSpecificCommunity
                                {
                                    NavigationLink(destination: CommunityView(account: account, community: post.community, feedType: feedType))
                                    {
                                        HStack(alignment: .center, spacing: 10)
                                        {                                           
                                            if shouldShowCommunityIcons
                                            {
                                                if let communityAvatarLink = post.community.icon
                                                {
                                                    AvatarView(avatarLink: communityAvatarLink, overridenSize: 30)
                                                }
                                            }

                                            Text(post.community.name)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }

                                if post.stickied
                                {
                                    Spacer()
                                    
                                    StickiedTag()
                                }
                            }

                            Text(post.name)
                                .font(.headline)
                        }
                    }
                    else
                    { // Show this when the post is expanded
                        VStack(alignment: .leading, spacing: 5)
                        {
                            if post.stickied
                            {
                                StickiedTag()
                            }
                            
                            Text(post.name)
                                .font(.headline)
                        }
                        .onTapGesture {
                            print("Tapped")
                            withAnimation(.easeIn(duration: 0.2)) {
                                isPostCollapsed.toggle()
                            }
                        }
                    }
                }

                VStack(alignment: .leading) {
                    if !isExpanded && postDisplayType == .fullDisplay
                    {
                        FullPostView(post: post, isPostCollapsed: $isPostCollapsed, isShowingEnlargedImage: $isShowingEnlargedImage, isExpanded: $isExpanded)
                    }
                    else if !isExpanded && postDisplayType == .compactDisplay
                    {
                        
                    }
                    else if isExpanded
                    {
                        FullPostView(post: post, isPostCollapsed: $isPostCollapsed, isShowingEnlargedImage: $isShowingEnlargedImage, isExpanded: $isExpanded)
                    }
                    else
                    {
                        FullPostView(post: post, isPostCollapsed: $isPostCollapsed, isShowingEnlargedImage: $isShowingEnlargedImage, isExpanded: $isExpanded)
                    }
                }
            }
            .padding()

            HStack
            {
                // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                HStack(alignment: .center)
                {
                    PostUpvoteButton(upvotes: post.upvotes, downvotes: post.downvotes, myVote: post.myVote)
                        .onTapGesture {
                            if post.myVote != .upvoted
                            {
                                Task(priority: .userInitiated) {
                                    print("Would upvote post")
                                    try await ratePost(post: post, operation: .upvote, account: account, postTracker: postTracker)
                                }
                            }
                            else if post.myVote == .upvoted
                            {
                                Task(priority: .userInitiated) {
                                    print("Would remove upvote")
                                    try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker)
                                }
                            }
                            else
                            {
                                print("This should never happen")
                            }
                        }
                    
                    PostDownvoteButton(myVote: post.myVote)
                        .onTapGesture {
                            if post.myVote != .downvoted
                            {
                                Task(priority: .userInitiated) {
                                    print("Would downvote post")
                                    try await ratePost(post: post, operation: .downvote, account: account, postTracker: postTracker)
                                }
                            }
                            else if post.myVote == .downvoted
                            {
                                Task(priority: .userInitiated) {
                                    print("Would remove downvote")
                                    try await ratePost(post: post, operation: .resetVote, account: account, postTracker: postTracker)
                                }
                            }
                            else
                            {
                                print("This should never happen")
                            }
                        }
                    
                    if let postURL = post.url
                    {
                        ShareButton(urlToShare: postURL, isShowingButtonText: false)
                    }
                }

                Spacer()

                // TODO: Refactor this into Post Info once I learn how to pass the vars further down
                HStack(spacing: 8)
                {

                    HStack(spacing: iconToTextSpacing)
                    { // Number of comments
                        Image(systemName: "bubble.left")
                        Text(String(post.numberOfComments))
                    }

                    HStack(spacing: iconToTextSpacing)
                    { // Time since posted
                        Image(systemName: "clock")
                        Text(getTimeIntervalFromNow(date: post.published))
                    }

                    UserProfileLink(user: post.author )
                }
                .foregroundColor(.secondary)
                .dynamicTypeSize(.small)
            }
            .padding(.horizontal)
            .if(!isExpanded, transform: { viewProxy in
                viewProxy
                    .padding(.bottom)
            })
            
            if isExpanded
            {
                Divider()
            }
        }
        .background(Color(uiColor: .systemBackground))
    }
}
