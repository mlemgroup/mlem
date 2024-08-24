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
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.openURL) var openURL
    
    @State var loading: ImageLoadingState?
    
    let post: any Post1Providing
    var blurred: Bool = false
    let size: Size
    
    enum Size {
        case standard, tile
    }
    
    var url: URL? {
        switch post.type {
        case let .image(url): url
        case let .link(link): link.thumbnail
        default: nil
        }
    }
    
    init(
        post: any Post1Providing,
        blurred: Bool,
        size: Size
    ) {
        self.post = post
        self.blurred = blurred
        self.size = size
    }
    
    var body: some View {
        switch post.type {
        case let .image(url):
            content
                .onTapGesture {
                    if let loading, loading == .done {
                        post.markRead()
                        
                        // Sheets don't cover the whole screen on iPad, so use a fullScreenCover instead
                        if UIDevice.isPad {
                            navigation.showFullScreenCover(.imageViewer(url))
                        } else {
                            print("DEBUGT tapped \(NSDate().timeIntervalSince1970)")
                            navigation.openSheet(.imageViewer(url))
                        }
                    }
                }
        case let .link(link):
            content
                .onTapGesture {
                    post.markRead()
                    openURL(link.content)
                }
        default:
            content
        }
    }
    
    @ViewBuilder
    var content: some View {
        switch size {
        case .standard: standardContent
        case .tile: tileContent
        }
    }
    
    @ViewBuilder
    var standardContent: some View {
        if let url {
            FixedImageView(
                url: url.withIconSize(Constants.main.feedImageResolution),
                maxSize: PostSize.compact.imageSize,
                fallback: .image,
                showProgress: true
            )
            .frame(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
            .dynamicBlur(blurred: blurred && loading == .done)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
            .onPreferenceChange(ImageLoadingPreferenceKey.self, perform: { loading = $0 })
        } else {
            Image(systemName: post.placeholderImageName)
                .font(.title)
                .frame(width: Constants.main.thumbnailSize, height: Constants.main.thumbnailSize)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
                .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
                .overlay(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
                    .stroke(palette.secondaryBackground, lineWidth: 1))
        }
    }
    
    @ViewBuilder
    var tileContent: some View {
        if let url {
            FixedImageView(
                url: url.withIconSize(Constants.main.feedImageResolution),
                maxSize: PostSize.tile.imageSize,
                fallback: .image,
                showProgress: true
            )
            .dynamicBlur(blurred: blurred)
            .onPreferenceChange(ImageLoadingPreferenceKey.self, perform: { loading = $0 })
        } else {
            Image(systemName: post.placeholderImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 50)
                .padding(4)
                .foregroundStyle(palette.tertiary)
        }
    }
}
