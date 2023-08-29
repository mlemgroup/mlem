//
//  UltraCompactPost.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-04.
//

import Dependencies
import Foundation
import SwiftUI

struct UltraCompactPost: View {
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
    
    @EnvironmentObject var postTracker: PostTracker

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // arguments
    let postModel: PostModel
    let showCommunity: Bool // true to show community name, false to show username
    let menuFunctions: [MenuFunction]
    
    // computed
    var showReadCheck: Bool { postModel.read && diffWithoutColor && readMarkStyle == .check }

    @available(*, deprecated, message: "Migrate to PostModel")
    init(postView: APIPostView, showCommunity: Bool, menuFunctions: [MenuFunction]) {
        self.postModel = PostModel(from: postView)
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
    }
    
    init(postModel: PostModel, showCommunity: Bool, menuFunctions: [MenuFunction]) {
        self.postModel = postModel
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
            if shouldShowPostThumbnails, !thumbnailsOnRight {
                ThumbnailImageView(postModel: postModel)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                HStack {
                    Group {
                        if showCommunity {
                            CommunityLinkView(community: postModel.community, serverInstanceLocation: .trailing, overrideShowAvatar: false)
                        } else {
                            UserProfileLink(
                                user: postModel.creator,
                                serverInstanceLocation: .trailing
                            )
                        }
                    }
                    
                    Spacer()
                    
                    if showReadCheck { ReadCheck() }
                    
                    EllipsisMenu(size: 12, menuFunctions: menuFunctions)
                        .padding(.trailing, 6)
                }
                .padding(.bottom, -2)
                
                Text(postModel.post.name)
                    .font(.subheadline)
                    .foregroundColor(postModel.read ? .secondary : .primary)
    
                compactInfo
            }
            
            if shouldShowPostThumbnails, thumbnailsOnRight {
                ThumbnailImageView(postModel: postModel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppConstants.postAndCommentSpacing)
    }
    
    @ViewBuilder
    private var compactInfo: some View {
        HStack(spacing: 8) {
            if postModel.post.featuredCommunity {
                if postModel.post.featuredLocal {
                    StickiedTag(tagType: .local, compact: true)
                } else if postModel.post.featuredCommunity {
                    StickiedTag(tagType: .community, compact: true)
                }
            }
            
            if postModel.post.nsfw || postModel.community.nsfw {
                NSFWTag(compact: true)
            }
            
            InfoStackView(
                votes: DetailedVotes(
                    score: postModel.votes.total,
                    upvotes: postModel.votes.upvotes,
                    downvotes: postModel.votes.downvotes,
                    myVote: postModel.votes.myVote ?? .resetVote,
                    showDownvotes: showDownvotesSeparately
                ),
                published: postModel.published,
                commentCount: postModel.numReplies,
                saved: postModel.saved,
                alignment: .center
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
