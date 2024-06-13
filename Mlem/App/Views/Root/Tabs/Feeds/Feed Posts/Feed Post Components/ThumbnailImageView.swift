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
    
    // TODO: (pending image handling) actually put an image in here
    
    let post: any Post1Providing
    
    var body: some View {
        switch post.type {
        case let .image(url):
            TappableImageView(url: url)
                .aspectRatio(contentMode: .fill)
                .frame(width: AppConstants.thumbnailSize, height: AppConstants.thumbnailSize)
                .background(palette.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
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
