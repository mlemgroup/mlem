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
    
    var showNsfwFilter: Bool { postView.post.nsfw && shouldBlurNsfw }
    
    var body: some View {
        HStack(spacing: AppConstants.postAndCommentSpacing) {
            thumbnailImage
            
            Text(postView.post.name)
            
            Spacer()
        }
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
}
