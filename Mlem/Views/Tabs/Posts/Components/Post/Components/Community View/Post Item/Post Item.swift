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

                                if post.post.featuredLocal
                                {
                                    Spacer()

                                    StickiedTag()
                                }
                            }

                            Text(post.post.name)
                                .font(.headline)
                        }
                    }
                    else
                    { // Show this when the post is expanded
                        VStack(alignment: .leading, spacing: 5)
                        {
                            if post.post.featuredLocal
                            {
                                StickiedTag()
                            }

                            Text(post.post.name)
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
                    if let postURL = post.post.url
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
                            WebsiteIconComplex(post: post.post)
                        }
                    }

                    if let postBody = post.post.body
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
                // TODO: Refactor this into Post Interactions once I learn how to pass the vars further down
                HStack(alignment: .center)
                {
                    HStack(alignment: .center, spacing: 2)
                    {
                        Image(systemName: "arrow.up")

                        Text(String(post.counts.score))
                    }
                    .if(post.myVote == .none || post.myVote == .downvote)
                    { viewProxy in
                        viewProxy
                            .foregroundColor(.accentColor)
                    }
                    .if(post.myVote == .upvote)
                    { viewProxy in
                        viewProxy
                            .foregroundColor(.green)
                    }
                    .onTapGesture
                    {
                        Task(priority: .userInitiated)
                        {
                            switch post.myVote
                            {
                            case .upvote:
                                try await ratePost(
                                    post: post.post,
                                    operation: .resetVote,
                                    account: account,
                                    postTracker: postTracker,
                                    appState: appState
                                )
                            case .downvote, .resetVote, .none:
                                try await ratePost(
                                    post: post.post,
                                    operation: .upvote,
                                    account: account,
                                    postTracker: postTracker,
                                    appState: appState
                                )
                            }
                        }
                    }

                    Image(systemName: "arrow.down")
                        .if(post.myVote == .downvote)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.red)
                        }
                        .if(post.myVote == .upvote || post.myVote == .none)
                        { viewProxy in
                            viewProxy
                                .foregroundColor(.accentColor)
                        }
                        .onTapGesture
                        {
                            Task(priority: .userInitiated)
                            {
                                switch post.myVote
                                {
                                case .downvote:
                                    try await ratePost(
                                        post: post.post,
                                        operation: .resetVote,
                                        account: account,
                                        postTracker: postTracker,
                                        appState: appState
                                    )
                                case .upvote, .resetVote, .none:
                                    try await ratePost(
                                        post: post.post,
                                        operation: .downvote,
                                        account: account,
                                        postTracker: postTracker,
                                        appState: appState
                                    )
                                }
                            }
                        }

                    if let postURL = post.post.url
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
                        Text(String(post.counts.comments))
                    }

                    HStack(spacing: iconToTextSpacing)
                    { // Time since posted
                        Image(systemName: "clock")
                        Text(getTimeIntervalFromNow(date: post.post.published))
                    }

                    UserProfileLink(account: account, user: post.creator)
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
