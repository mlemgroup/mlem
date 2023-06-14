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
    let post: APIPostView
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
                    Text(post.post.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.trailing)
                    
                    HStack(spacing: 4) {
                        // stickied
                        if post.post.featuredLocal { StickiedTag(compact: true) }
                        
                        // community name
                        NavigationLink(destination: CommunityView(account: account, community: post.community, feedType: .all)) {
                            Text(post.community.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Text("by")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        // poster
                        NavigationLink(destination: UserView(userID: post.creator.id, account: account)) {
                            Text(post.creator.name)
                                .font(.caption)
                                .italic()
                                .if (post.creator.admin) { viewProxy in
                                    viewProxy
                                        .foregroundColor(.red)
                                }
                                .if (post.creator.botAccount) { viewProxy in
                                    viewProxy
                                        .foregroundColor(.indigo)
                                }
                                .if (post.creator.name == "lFenix") { viewProxy in
                                    viewProxy
                                        .foregroundColor(.yellow)
                                }
                                .if (!(post.creator.admin || post.creator.botAccount || post.creator.name == "lFenix")) { viewProxy in
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
            
            PostInteractionBar(post: post, account: account, compact: true, voteOnPost: voteOnPost)
        }
    }
}
