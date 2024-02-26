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
    @Dependency(\.errorHandler) var errorHandler
    
    @Environment(\.accessibilityDifferentiateWithoutColor) var diffWithoutColor: Bool
    
    // arguments
    let post: any Post2Providing
    let showCommunity: Bool // true to show community name, false to show username

    // computed
    var showReadCheck: Bool { post.isRead && diffWithoutColor && readMarkStyle == .check }
    
    init(post: any Post2Providing, showCommunity: Bool) {
        self.post = post
        self.showCommunity = showCommunity
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
                            CommunityLinkView(
                                community: post.community,
                                serverInstanceLocation: .trailing,
                                overrideShowAvatar: false
                            )
                        } else {
                            PersonLinkView(
                                person: post.creator,
                                serverInstanceLocation: .trailing,
                                communityContext: post.community
                            )
                        }
                    }
                    
                    Spacer()
                    
                    if showReadCheck { ReadCheck() }
                    
                    EllipsisMenu(size: 12, menuFunctions: post.menuFunctions)
                        .padding(.trailing, 6)
                }
                .padding(.bottom, -2)
                
                Text(post.title)
                    .font(.subheadline)
                    .foregroundColor(post.isRead ? .secondary : .primary)
    
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
            if post.pinnedInstance {
                StickiedTag(tagType: .local, compact: true)
            } else if post.pinnedCommunity {
                StickiedTag(tagType: .community, compact: true)
            }
            
            if post.nsfw || post.community.nsfw {
                NSFWTag(compact: true)
            }
            
            InfoStackView(
                votes: DetailedVotes(
                    score: post.score,
                    upvotes: post.upvoteCount,
                    downvotes: post.downvoteCount,
                    myVote: post.myVote,
                    showDownvotes: showDownvotesSeparately
                ),
                published: post.creationDate,
                updated: post.updatedDate,
                commentCount: post.commentCount,
                unreadCommentCount: post.unreadCommentCount,
                saved: post.isSaved,
                alignment: .center,
                colorizeVotes: true
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
