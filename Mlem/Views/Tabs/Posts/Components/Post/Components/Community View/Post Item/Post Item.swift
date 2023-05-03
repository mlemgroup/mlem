//
//  Post in the List.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI

struct Post_Item: View
{
    @EnvironmentObject var isInSpecificCommunity: IsInSpecificCommunity
    
    @State var post: Post
    
    @State var isExpanded: Bool
    
    let iconToTextSpacing: CGFloat = 2

    var body: some View
    {
        VStack(alignment: .leading)
        {
            VStack(alignment: .leading)
            {
                HStack(alignment: .top)
                {
                    if !isExpanded
                    { // Show this when the post is just in the list and not expanded
                        VStack(alignment: .leading, spacing: 8)
                        {
                            HStack
                            {
                                if !isInSpecificCommunity.isInSpecificCommunity
                                {
                                    NavigationLink(destination: Community_View(communityName: post.communityName, communityID: post.communityID))
                                    {
                                        Text(post.communityName)
                                    }
                                    .buttonStyle(.plain)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }

                                if let isStickied = post.stickied
                                {
                                    if isStickied
                                    {
                                        Stickied_Tag()
                                    }
                                }
                            }

                            Text(post.name)
                                .font(.subheadline)
                        }
                    }
                    else
                    { // Show this when the post is expanded
                        Text(post.name)
                            .font(.headline)

                        if let isStickied = post.stickied
                        { // TODO: Make it look the right way when the post is expanded
                            if isStickied
                            {
                                Stickied_Tag()
                            }
                        }
                    }
                }

                if post.stickied != nil && !isExpanded
                { // If the text is stickied, only show the title. If the user expands the stickied post, make sure it actually has content
                }
                else
                {
                    if post.body == nil
                    { // First, if there's nothing in the body, it means it's not a normal text post, so...
                        if post.thumbnailURL != nil
                        { // Show an image if there is no text in the body. But only show it if there actually is one.
                            VStack(alignment: .leading)
                            {
                                AsyncImage(url: URL(string: post.thumbnailURL!))
                                { phase in
                                    if let image = phase.image
                                    { // Display the image if it successfully loaded
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .onTapGesture
                                            {
                                                // TODO: Make it so that tapping an image makes it big
                                            }
                                    }
                                    else if phase.error != nil
                                    { // Show some kind of an error in case the image failed to load
                                        Error_View(errorMessage: "This image failed to load")
                                    }
                                    else
                                    { // While loading, show a placeholder
                                        Loading_View(whatIsLoading: .image)
                                    }
                                }

                                if post.url != nil
                                { // Sometimes, these pictures are just links to other sites. If that's the case, add the link under the picture
                                    VStack(alignment: .leading)
                                    {
                                        // This shit doesn't work properly        let urlURLfied = URL(string: url!)
                                        // Maybe bug in xCode?                    Text("\(urlURLfied?.host)")
                                        Text(.init(post.url!))
                                            .dynamicTypeSize(.small)
                                            .lineLimit(1)
                                            .padding([.horizontal, .bottom])
                                    }
                                }
                            }
                            .background(Color.secondarySystemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        else if post.url != nil
                        { // Second option is that it's a post with just a link and no body. Then just show the link
                            // TODO: Make the text look nicer. Maybe something like iMessage has when you send a link
                            Text(.init(post.url!))
                        }
                        else
                        { // I have no idea why this would happen
                            Text("ERR: Unexpected post format")
                        }
                    }
                    else
                    { // Third option is it being a text post. Show that text here.
                        if isExpanded
                        {
                            Text(.init(post.body!)) // .init for Markdown support
                                .dynamicTypeSize(.small)
                                .padding(.top, 2)
                        }
                        else
                        {
                            Text(.init(post.body!)) // .init for Markdown support
                                .foregroundColor(.secondary)
                                .dynamicTypeSize(.small)
                                .lineLimit(3)
                                .padding(.top, 2)
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
                    Upvote_Button(score: post.score)
                    Downvote_Button()
                    if let postURL = post.url
                    {
                        Share_Button(urlToShare: post.url!)
                    }
                }

                Spacer()

                // TODO: Refactor this into Post Info once I learn how to pass the vars further down
                HStack(spacing: 8)
                {
                    /* HStack(spacing: iconToTextSpacing) { // Number of upvotes
                         Image(systemName: "arrow.up")
                         Text(String(score))
                     } */

                    HStack(spacing: iconToTextSpacing)
                    { // Number of comments
                        Image(systemName: "bubble.left")
                        Text(String(post.numberOfComments))
                    }

                    HStack(spacing: iconToTextSpacing)
                    { // Time since posted
                        Image(systemName: "clock")
                        Text(getTimeIntervalFromNow(originalTime: post.published))
                    }

                    User_Profile_Link(userName: post.creatorName)
                }
                .foregroundColor(.secondary)
                .dynamicTypeSize(.small)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(uiColor: .systemBackground))
    }
}
