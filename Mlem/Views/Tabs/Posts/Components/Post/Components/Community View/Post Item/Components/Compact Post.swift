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
    let thumbnailSize: CGFloat = 60
    
    // @EnvironmentObject var postTracker: PostTracker
    @State var postTracker: PostTracker
    
    let post: APIPostView
    
    var account: SavedAccount
    
    var body: some View {
        VStack(spacing: 0) {
            HStack() {
                
                if let postURL = post.post.url {
                    // image post: display image
                    if postURL.pathExtension.contains(["jpg", "jpeg", "png"]) {
                        CachedAsyncImage(url: postURL) { image in
                            image
                                .resizable()
                                .frame(width: thumbnailSize, height: thumbnailSize)
                                .scaledToFill()
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        } placeholder: {
                            ProgressView()
                                .frame(width: thumbnailSize, height: thumbnailSize)
                        }
                    }
                    
                    // web post: display link
                    else {
                        Image(systemName: "safari")
                            .frame(width: thumbnailSize, height: thumbnailSize)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .stroke(.secondary, lineWidth: 2))
                    }
                }
                else {
                    Image(systemName: "text.book.closed")
                        .frame(width: thumbnailSize, height: thumbnailSize)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 4)
                            .stroke(.secondary, lineWidth: 2))
                }
                
                
                Text(post.post.name)
                    .font(.callout)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.trailing)
                    //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    //.padding(.top, 4)
                    
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            PostInteractionBar(postTracker: postTracker, post: post, account: account, compact: true)
        }
    }
}
