//
//  ThumbnailImage.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-29.
//

import Foundation
import SwiftUI

struct ThumbnailImage: View {
    
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    let postView: APIPostView
    
    var showNsfwFilter: Bool { (postView.post.nsfw || postView.community.nsfw) && shouldBlurNsfw }
    
    var body: some View {
        Group {
            switch postView.postType {
            case .image(let url):
                // just blur, no need for the whole filter viewModifier since this is just a thumbnail
                CachedImage(url: url)
                    .blur(radius: showNsfwFilter ? 8 : 0)
            case .link(let url):
                CachedImage(url: url)
                    .blur(radius: showNsfwFilter ? 8 : 0)
            case .text:
                Image(systemName: "text.book.closed")
            case .titleOnly:
                Image(systemName: "character.bubble")
            }
        }
        .foregroundColor(.secondary)
        .font(.title)
        .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
        .background(Color(UIColor.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        .overlay(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
    }
}
