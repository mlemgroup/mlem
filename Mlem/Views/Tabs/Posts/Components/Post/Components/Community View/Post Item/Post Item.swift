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
    
    @EnvironmentObject var appState: AppState
    
    @State var postTracker: PostTracker

    let post: APIPostView

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
                        .onTapGesture
                        {
                            print("Tapped")
                            withAnimation(.easeIn(duration: 0.2))
                            {
                                isPostCollapsed.toggle()
                            }
                        }
                    }
                }

                VStack(alignment: .leading)
                {
                    if let postURL = post.url
                    {
                        if postURL.pathExtension.contains(["jpg", "jpeg", "png"]) /// The post is an image, so show an image
                        {
                            if !isPostCollapsed
                            {
                                CachedAsyncImage(url: postURL)
                                { image in
                                    image
                                        .resizable()
                                        .frame(maxWidth: .infinity)
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                                .stroke(Color(.secondarySystemBackground), lineWidth: 1.5)
                                        )
                                        .onTapGesture
                                        {
                                            isShowingEnlargedImage.toggle()
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        else
                        {
                            if post.embedTitle != nil
                            {
                                WebsiteIconComplex(post: post)
                            }
                            else
                            {
                                WebsiteIconComplex(post: post)
                            }
                        }
                    }

                    if let postBody = post.body
                    {
                        if !postBody.isEmpty
                        {
                            if !isExpanded
                            {
                                MarkdownView(text: postBody)
                                    .font(.subheadline)
                            }
                            else
                            {
                                if !isPostCollapsed
                                {
                                    MarkdownView(text: postBody)
                                        .onTapGesture
                                        {
                                            print("Tapped")
                                            withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5))
                                            {
                                                isPostCollapsed.toggle()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .padding()

            HStack
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
                if (!compact){
                    LargePostPreview(post: post, account: account)
                        .padding(.bottom)
                }
                
                // TODO: compact post preview
                
                if !compact {
                    Divider()
                }
                
                PostInteractionBar(post: post, upvoteCallback: upvotePost, downvoteCallback: downvotePost, saveCallback: savePost)
                    .if(!compact) { viewProxy in
                        viewProxy.padding(.vertical, 4)
                    }
            }.if(!compact) { viewProxy in
                viewProxy.padding(.top)
            }
            .background(Color.systemBackground)
        }
        .buttonStyle(EmptyButtonStyle())
    }
    
}

