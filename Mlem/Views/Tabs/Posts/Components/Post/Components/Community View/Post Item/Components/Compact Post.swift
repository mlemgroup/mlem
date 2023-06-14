//
//  Compact Post.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import CachedAsyncImage
import Foundation
import SwiftUI

struct CompactPost: View {
    // constants
    let thumbnailSize: CGFloat = 60
    
    // arguments
    let postView: APIPostView
    let account: SavedAccount
    let voteOnPost: (ScoringOperation) async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(alignment: .top) {
                switch post.postType {
                case .image(let url):
                    CachedAsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: thumbnailSize, height: thumbnailSize)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(.secondary, lineWidth: 1))
                    } placeholder: {
                        ProgressView()
                            .frame(width: thumbnailSize, height: thumbnailSize)
                    }
                case .link:
                    Image(systemName: "safari")
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary, lineWidth: 1))
                case .text:
                    Image(systemName: "text.book.closed")
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary, lineWidth: 1))
                case .titleOnly:
                    Image(systemName: "character.bubble")
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary, lineWidth: 1))
                }
                
                VStack(spacing: 2) {
                    Text(postView.post.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.trailing)
                    
                    HStack(spacing: 4) {
                        // stickied
                        if postView.post.featuredLocal { StickiedTag(compact: true) }
                        if postView.post.nsfw { NSFWTag(compact: true) }
                        
                        // community name
                        NavigationLink(destination: CommunityView(account: account, community: postView.community, feedType: .all)) {
                            Text(postView.community.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Text("by")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        // poster
                        NavigationLink(destination: UserView(userID: postView.creator.id, account: account)) {
                            Text(postView.creator.name)
                                .font(.caption)
                                .italic()
                                .if (postView.creator.admin) { viewProxy in
                                    viewProxy
                                        .foregroundColor(.red)
                                }
                                .if (postView.creator.botAccount) { viewProxy in
                                    viewProxy
                                        .foregroundColor(.indigo)
                                }
                                .if (postView.creator.name == "lFenix") { viewProxy in
                                    viewProxy
                                        .foregroundColor(.yellow)
                                }
                                .if (!(postView.creator.admin || postView.creator.botAccount || postView.creator.name == "lFenix")) { viewProxy in
                                    viewProxy
                                        .foregroundColor(.secondary)
                                }
                        }
                        
                        Spacer()
                    }
                }
                
            }
            
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            PostInteractionBar(post: postView, account: account, compact: true, voteOnPost: voteOnPost)
        }
    }
    
    @ViewBuilder
    private var thumbnailImage: some View {
        switch postView.postType {
        case .image:
            // force unwrapping safe because postType performs nil check
            CachedAsyncImage(url: postView.post.url!) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .blur(radius: postView.post.nsfw ? 8 : 0) // blur nsfw
                    
            } placeholder: {
                ProgressView()
            }
        case .link:
            Image(systemName: "safari")
        case .text:
            Image(systemName: "text.book.closed")
        case .error:
            Image(systemName: "exclamationmark.triangle")
        }
    }
}
