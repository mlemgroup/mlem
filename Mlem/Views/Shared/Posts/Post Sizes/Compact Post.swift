//
//  Compact Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-04.
//

import Dependencies
import Foundation
import SwiftUI

struct CompactPost: View {
    // app storage
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("thumbnailsOnRight") var thumbnailsOnRight: Bool = false
    @AppStorage("showDownvotesSeparately") var showDownvotesSeparately: Bool = false
    
    @AppStorage("reakMarkStyle") var readMarkStyle: ReadMarkStyle = .bar
    
    // environment and dependencies
    @Dependency(\.postRepository) var postRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // arguments
    let post: PostModel
    let community: CommunityModel?
    let showCommunity: Bool // true to show community name, false to show username
    let menuFunctions: [MenuFunction]
    
    // computed
    var showReadCheck: Bool { post.read && diffWithoutColor && readMarkStyle == .check }
    
    init(post: PostModel, community: CommunityModel? = nil, showCommunity: Bool, menuFunctions: [MenuFunction]) {
        self.post = post
        self.community = community
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
            if shouldShowPostThumbnails, !thumbnailsOnRight {
                ThumbnailImageView(post: post)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    Group {
                        if showCommunity {
                            CommunityLinkView(community: post.community, serverInstanceLocation: .trailing, overrideShowAvatar: false)
                        } else {
                            UserLinkView(
                                user: post.creator,
                                serverInstanceLocation: .trailing,
                                communityContext: community
                            )
                        }
                    }
                    
                    Spacer()
                    
                    if showReadCheck { ReadCheck() }
                    
                    EllipsisMenu(size: 12, menuFunctions: menuFunctions)
                        .padding(.trailing, 6)
                }
                .padding(.bottom, -2)
                
                Text(post.post.name)
                    .font(.subheadline)
                    .foregroundColor(post.read ? .secondary : .primary)
    
                compactInfo
            }
            
            if shouldShowPostThumbnails, thumbnailsOnRight {
                ThumbnailImageView(post: post)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.postAndCommentSpacing)
    }
    
    @ViewBuilder
    private var compactInfo: some View {
        HStack(spacing: 8) {
            if post.post.featuredCommunity {
                if post.post.featuredLocal {
                    StickiedTag(tagType: .local, compact: true)
                } else if post.post.featuredCommunity {
                    StickiedTag(tagType: .community, compact: true)
                }
            }
            
            if post.post.nsfw || post.community.nsfw {
                NSFWTag(compact: true)
            }
            
            InfoStackView(
                votes: DetailedVotes(
                    score: post.votes.total,
                    upvotes: post.votes.upvotes,
                    downvotes: post.votes.downvotes,
                    myVote: post.votes.myVote,
                    showDownvotes: showDownvotesSeparately
                ),
                published: post.published,
                updated: post.updated,
                commentCount: post.commentCount,
                unreadCommentCount: post.unreadCommentCount,
                saved: post.saved,
                alignment: .center,
                colorizeVotes: true
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
