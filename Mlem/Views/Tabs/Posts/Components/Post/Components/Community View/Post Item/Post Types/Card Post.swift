//
//  Card Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-16.
//

import Foundation
import SwiftUI

struct CardPost: View {
    
    // arguments
    let postView: APIPostView
    
    // computed
    var dimension: CGFloat { UIScreen.main.bounds.width / 2 }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Divider()
            
            VStack(alignment: .leading, spacing: AppConstants.cardPostSpacing) {
                VStack(alignment: .leading, spacing: AppConstants.iconToTextSpacing) {
                    NavigationLink(value: postView.community) {
                        Text(postView.community.name)
                            .bold()
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(postView.post.name)
                        .font(.subheadline)
                        .bold()
                        .lineLimit(2)
                }
                
                postContentView
                
                InfoStack(score: postView.counts.score,
                          myVote: postView.myVote ?? .resetVote,
                          published: postView.published,
                          commentCount: postView.counts.comments,
                          saved: postView.saved,
                          fontSize: .caption)
                .frame(maxWidth: .infinity)
            }
            .padding(AppConstants.cardPostSpacing)
            
            Divider()
        }
        .frame(width: dimension, height: dimension)
    }
    
    @ViewBuilder
    var postContentView: some View {
        switch postView.postType {
        case .image(let url):
            GeometryReader { proxy in
                CachedImage(url: url)
                    .cornerRadius(AppConstants.largeItemCornerRadius)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .applyNsfwOverlay(postView.post.nsfw || postView.community.nsfw)
                    .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
            }
        case .link:
            GeometryReader { proxy in
                Group {
                    if let thumbnailURL = postView.post.thumbnailUrl {
                        CachedImage(url: thumbnailURL)
                            .cornerRadius(AppConstants.largeItemCornerRadius)
                    } else {
                        Image(systemName: "safari")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    HStack(spacing: AppConstants.iconToTextSpacing) {
                        Image(systemName: "link")
                            .imageScale(.small)
                        
                        Text(postView.post.url?.host ?? "the web")
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(AppConstants.iconToTextSpacing)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .frame(maxHeight: .infinity, alignment: .bottomLeading)
                }
                .applyNsfwOverlay(postView.post.nsfw || postView.community.nsfw)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
            }
        case .text(let postBody):
            MarkdownView(text: postBody, isNsfw: postView.post.nsfw)
                .lineLimit(3)
                .font(.subheadline)
        case .titleOnly:
            EmptyView()
        }
    }
}
