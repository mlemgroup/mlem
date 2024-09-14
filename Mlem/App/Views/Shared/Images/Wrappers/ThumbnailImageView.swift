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
    @State var quickLookUrl: URL?
    
    let post: any Post1Providing
    var blurred: Bool = false
    let size: Size
    let frame: CGSize
    
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
        size: Size,
        frame: CGSize
    ) {
        self.post = post
        self.blurred = blurred
        self.size = size
        self.frame = frame
    }
    
    var body: some View {
        Group {
            switch post.type {
            case let .image(url):
                content
                    .onTapGesture {
                        if let loading, loading == .done || loading == .proxyFailed {
                            post.markRead()
                            
                            // Sheets don't cover the whole screen on iPad, so use a fullScreenCover instead
                            if UIDevice.isPad {
                                navigation.showFullScreenCover(.imageViewer(url))
                            } else {
                                navigation.openSheet(.imageViewer(url))
                            }
                        }
                    }
                    .contextMenu {
                        if let url = fullSizeUrl(url: url) {
                            Button("Save Image", systemImage: Icons.import) {
                                Task { await saveImage(url: url) }
                            }
                            Button("Share Image", systemImage: Icons.share) {
                                Task { await shareImage(url: url) }
                            }
                            Button("Quick Look", systemImage: Icons.imageDetails) {
                                Task { await showQuickLook(url: url) }
                            }
                        }
                    }
                    .quickLookPreview($quickLookUrl)
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
        .frame(width: frame.width, height: frame.width)
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
                size: frame,
                fallback: .image,
                showProgress: true
            )
            .dynamicBlur(blurred: blurred && loading == .done)
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
            .onPreferenceChange(ImageLoadingPreferenceKey.self, perform: { loading = $0 })
        } else {
            Image(systemName: post.placeholderImageName)
                .font(.title)
                .frame(width: frame.width, height: frame.width)
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
                size: frame,
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
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "image") {
            navigation.shareUrl = fileUrl
        }
    }
    
    func showQuickLook(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "quicklook") {
            quickLookUrl = fileUrl
        }
    }
}
