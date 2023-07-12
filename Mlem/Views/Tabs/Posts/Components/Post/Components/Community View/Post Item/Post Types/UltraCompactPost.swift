//
//  UltraCompactPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-04.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct UltraCompactPost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = false
    @AppStorage("thumbnailsOnRight") var thumbnailsOnRight: Bool = false

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // arguments
    let postView: APIPostView
    let showCommunity: Bool // true to show community name, false to show username
    let menuFunctions: [MenuFunction]
    
    // computed
    let voteColor: Color
    let voteIconName: String
    var showNsfwFilter: Bool { postView.post.nsfw && shouldBlurNsfw }

    init(postView: APIPostView, showCommunity: Bool, menuFunctions: [MenuFunction]) {
        self.postView = postView
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
        
        switch postView.myVote {
        case .upvote:
            voteIconName = "arrow.up"
            voteColor = .upvoteColor
        case .downvote:
            voteIconName = "arrow.down"
            voteColor = .downvoteColor
        default:
            voteIconName = "arrow.up"
            voteColor = .secondary
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
            if shouldShowPostThumbnails && !thumbnailsOnRight {
                thumbnailImage
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Group {
                        if showCommunity {
                            CommunityLinkView(community: postView.community, serverInstanceLocation: .trailing, overrideShowAvatar: false)
                        } else {
                            UserProfileLink(user: postView.creator, serverInstanceLocation: .trailing)
                        }
                    }
                    
                    Spacer()
                    
                    EllipsisMenu(size: 12, menuFunctions: menuFunctions)
                        .padding(.trailing, 6)
                }
                .padding(.bottom, -2)
                
                Text(postView.post.name)
                    .font(.subheadline)
    
                compactInfo
            }
            
            if shouldShowPostThumbnails && thumbnailsOnRight {
                thumbnailImage
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.postAndCommentSpacing)
    }
    
    @ViewBuilder
    private var thumbnailImage: some View {
        Group {
            switch postView.postType {
            case .image(let url):
                CachedAsyncImage(url: url, urlCache: AppConstants.urlCache) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                } placeholder: {
                    ProgressView()
                }
            case .link(let url):
                CachedAsyncImage(url: url, urlCache: AppConstants.urlCache) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .blur(radius: showNsfwFilter ? 8 : 0) // blur nsfw
                } placeholder: {
                    Image(systemName: "safari")
                }
            case .text:
                Image(systemName: "text.book.closed")
            case .titleOnly:
                Image(systemName: "character.bubble")
            }
        }
        .foregroundColor(.secondary)
        .font(.title)
        .frame(width: thumbnailSize, height: thumbnailSize)
        .background(Color(UIColor.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
    }
    
    @ViewBuilder
    private var compactInfo: some View {
        HStack(spacing: 8) {
            if postView.post.featuredCommunity {
                if postView.post.featuredLocal {
                    StickiedTag(tagType: .local, compact: true)
                } else if postView.post.featuredCommunity {
                    StickiedTag(tagType: .community, compact: true)
                }
            }
            
            if postView.post.nsfw || postView.community.nsfw {
                NSFWTag(compact: true)
            }
            
            InfoStack(score: postView.counts.score,
                      myVote: postView.myVote ?? .resetVote,
                      published: postView.published,
                      commentCount: postView.counts.comments,
                      saved: postView.saved)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
