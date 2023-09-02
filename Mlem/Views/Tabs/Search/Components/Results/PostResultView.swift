//
//  UltraCompactPost.swift
//  Mlem
//
//  Created by Sjmarf on 2023-08-31
//

import Dependencies
import Foundation
import SwiftUI
import MarkdownUI

struct PostResultView: View {
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
    @EnvironmentObject var searchModel: SearchModel

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    let resultPadding: Int = 70
    
    // arguments
    let postView: APIPostView
    let showCommunity: Bool // true to show community name, false to show username
    let menuFunctions: [MenuFunction]
    
    var postContent: String? = nil
    
    // computed
    var showReadCheck: Bool { postView.read && diffWithoutColor && readMarkStyle == .check }

    init(postView: APIPostView, showCommunity: Bool, searchModel: SearchModel, menuFunctions: [MenuFunction] = .init()) {
        self.postView = postView
        self.showCommunity = showCommunity
        self.menuFunctions = menuFunctions
        let sanitisedInput = searchModel.input.lowercased()
        
        if !postView.post.name.lowercased().contains(sanitisedInput), let body = postView.post.body {
            let sanitisedBody = MarkdownContent(body).renderPlainText()
            if let index = sanitisedBody.lowercased().range(of: sanitisedInput)?.lowerBound {
                
                let nearStart = sanitisedBody.distance(from: sanitisedBody.startIndex, to: index) < resultPadding
                let startIndex = nearStart ? sanitisedBody.startIndex : sanitisedBody.index(index, offsetBy: -resultPadding)
                
                let nearEnd = sanitisedBody.distance(from: index, to: sanitisedBody.endIndex) < resultPadding
                let endIndex = nearEnd ? sanitisedBody.endIndex : sanitisedBody.index(index, offsetBy: resultPadding)
                
                postContent = String(sanitisedBody[startIndex..<endIndex])
                    .replacingOccurrences(of: "\n", with: " ")
                    .replacingOccurrences(of: "\r", with: " ")
                if !nearStart {
                    postContent = "...\(postContent!)"
                }
                if !nearEnd {
                    postContent = "\(postContent!)..."
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: AppConstants.postAndCommentSpacing) {
                if shouldShowPostThumbnails, !thumbnailsOnRight {
                    ThumbnailImageView(postView: postView)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.compactSpacing) {
                    HStack {
                        Group {
                            if showCommunity {
                                CommunityLinkView(community: postView.community, serverInstanceLocation: .trailing, overrideShowAvatar: false)
                            } else {
                                UserLinkView(
                                    user: postView.creator,
                                    serverInstanceLocation: .trailing
                                )
                            }
                        }
                        
                        Spacer()
                        
                        if showReadCheck { ReadCheck() }
                        
                        if !menuFunctions.isEmpty {
                            EllipsisMenu(size: 12, menuFunctions: menuFunctions)
                                .padding(.trailing, 6)
                        }
                    }
                    .padding(.bottom, -2)
                    
                    SearchResultTextView(postView.post.name, highlight: searchModel.input)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                    
                    compactInfo
                    
                }
                
                if shouldShowPostThumbnails, thumbnailsOnRight {
                    ThumbnailImageView(postView: postView)
                }
            }
            .padding(.horizontal, 14)
            if let postContent = postContent {
                Divider()
                    .padding(.vertical, 4)
                SearchResultTextView(postContent, highlight: searchModel.input)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
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
            
            InfoStackView(
                votes: DetailedVotes(
                    score: postView.counts.score,
                    upvotes: postView.counts.upvotes,
                    downvotes: postView.counts.downvotes,
                    myVote: postView.myVote ?? .resetVote,
                    showDownvotes: showDownvotesSeparately
                ),
                published: postView.published,
                commentCount: postView.counts.comments,
                saved: postView.saved,
                alignment: .center
            )
            .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
