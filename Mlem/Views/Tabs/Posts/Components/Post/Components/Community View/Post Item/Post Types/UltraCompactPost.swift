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

    // constants
    let thumbnailSize: CGFloat = 60
    private let spacing: CGFloat = 10 // constant for readability, ease of modification
    
    // arguments
    let postView: APIPostView
    let account: SavedAccount
    let menuFunctions: [MenuFunction]
    
    // computed
    let voteColor: Color
    let voteIconName: String
    var showNsfwFilter: Bool { postView.post.nsfw && shouldBlurNsfw }
    var publishedAgo: String { getTimeIntervalFromNow(date: postView.post.published )}

    init(postView: APIPostView, account: SavedAccount, menuFunctions: [MenuFunction]) {
        self.postView = postView
        self.account = account
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
            thumbnailImage
            
            VStack(alignment: .leading, spacing: 6) {
                UserProfileLink(user: postView.creator, serverInstanceLocation: .trailing, showAvatar: false)
                    .padding(.bottom, -2)
                
                Text(postView.post.name)
                    .font(.subheadline)
                
                compactInfo
            }
            
            Spacer()
        }
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
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4)
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
    }
    
    @ViewBuilder
    private var compactInfo: some View {
        HStack(spacing: AppConstants.postAndCommentSpacing) {
            HStack(spacing: 2) {
                Image(systemName: voteIconName)
                Text(postView.counts.score.description)
            }
            .foregroundColor(voteColor)
            .accessibilityElement(children: .combine)
            
            HStack(spacing: 2) {
                Image(systemName: "bubble.right")
                Text(postView.counts.comments.description)
            }
            .accessibilityElement(children: .combine)
            
            HStack(spacing: 2) {
                Image(systemName: "clock")
                Text(publishedAgo.description)
            }
            .accessibilityElement(children: .combine)
            
            EllipsisMenu(size: 12, menuFunctions: menuFunctions)
        }
        .font(.footnote)
        .foregroundColor(.secondary)
    }
}
