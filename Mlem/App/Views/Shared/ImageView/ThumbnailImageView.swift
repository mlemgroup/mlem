//
//  ThumbnailImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct ThumbnailImageView: View {
    @Environment(Palette.self) var palette
    @Environment(\.openURL) var openURL
            
    let post: any Post1Providing
    var blurred: Bool = false
    
    init(post: any Post1Providing, blurred: Bool) {
        @AppStorage("safety.blurNsfw") var shouldBlur = true

        self.post = post
        self.blurred = shouldBlur ? blurred : false
    }
    
    var body: some View {
        switch post.type {
        case let .image(url):
            ExpandableImageView(url: url)
                .aspectRatio(contentMode: .fill)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .background(palette.secondaryBackground)
                .blur(radius: blurred ? 10 : 0, opaque: true)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        case let .link(link):
            ImageView(url: link.thumbnail)
                .aspectRatio(contentMode: .fill)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .background(palette.secondaryBackground)
                .blur(radius: blurred ? 10 : 0, opaque: true)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
                .onTapGesture {
                    openURL(link.content)
                }
        default:
            Image(systemName: post.placeholderImageName)
                .font(.title)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
                .overlay(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius)
                    .stroke(palette.secondaryBackground, lineWidth: 1))
        }
    }
}
