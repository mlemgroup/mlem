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
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @EnvironmentObject var appState: AppState

    @State var post: Post

    @State var isExpanded: Bool
    
    @State var isInSpecificCommunity: Bool
    
    @State var instanceAddress: URL
    
    @State var account: SavedAccount
    
    @State private var isShowingSafari: Bool = false
    @State private var isShowingEnlargedImage: Bool = false
    
    @State private var isPostCollapsed: Bool = false

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
                                    NavigationLink(destination: CommunityView(instanceAddress: instanceAddress, account: account, community: post.community))
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
                                        .onTapGesture {
                                            isShowingEnlargedImage.toggle()
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        }
                        else
                        {
                            if let embedTitle = post.embedTitle
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
                            if !post.stickied
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
                                            .onTapGesture {
                                                print("Tapped")
                                                withAnimation(.easeIn(duration: 0.2)) {
                                                    isPostCollapsed.toggle()
                                                }
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
                // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                HStack(alignment: .center)
                {
                    UpvoteButton(score: post.score)
                    DownvoteButton()
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
        .onAppear
        {
            print("Access token from within the view: \(account.accessToken)")
        }
    }
}
