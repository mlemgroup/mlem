//
//  Full View.swift
//  Mlem
//
//  Created by David Bureš on 03.06.2023.
//

import SwiftUI
import CachedAsyncImage

struct FullPostView: View {
    
    var post: Post
    
    @Binding var isPostCollapsed: Bool
    @Binding var isShowingEnlargedImage: Bool
    @Binding var isExpanded: Bool
    
    var body: some View {
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
                                .onTapGesture {
                                    print("Tapped")
                                    withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.5)) {
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

