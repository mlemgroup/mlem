//
//  ThumbnailImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-19.
//

import Foundation
import MlemMiddleware
import QuickLook
import SwiftUI

struct ThumbnailImageView: View {
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.openURL) var openURL
    
    @Setting(\.websiteThumbnailIcon) var websiteThumbnailIcon
    
    // @State var loading: MediaLoadingState?
    @State var loadingTracker: MediaLoadingTracker = .init()
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
        case let .media(url), let .embedded(url, _): url
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
            case let .media(url), let .embedded(url, _):
                content
                    .onTapGesture {
                        if let loading = loadingTracker.loading, loading == .done || loading == .proxyFailed {
                            post.markRead()
                            navigation.showImageViewer(url: url)
                        }
                    }
                    .contextMenu {
                        if let url = fullSizeUrl(url: url) {
                            Button("Save", systemImage: Icons.import) {
                                Task { await saveMedia(url: url) }
                            }
                            Button("Share...", systemImage: Icons.share) {
                                Task { await shareImage(url: url) }
                            }
                        }
                    }
                    .quickLookPreview($quickLookUrl)
            case let .link(link):
                content
                    .overlay {
                        if websiteThumbnailIcon {
                            Image(systemName: Icons.browser)
                                .frame(width: 16, height: 16)
                                .foregroundStyle(.white)
                                .background(.ultraThinMaterial, in: .circle)
                                .padding(4)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
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
                url: url,
                size: frame,
                fallback: url.proxyAwarePathExtension?.isMovieExtension ?? false ? .movie : .image,
                showProgress: true,
                blurred: blurred && loadingTracker.loading == .done
            )
            .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
            .environment(\.loadingTracker, loadingTracker)
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
                url: url,
                size: frame,
                fallback: .image,
                showProgress: true,
                blurred: blurred && loadingTracker.loading == .done
            )
            .environment(\.loadingTracker, loadingTracker)
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
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            navigation.shareInfo = .init(url: fileUrl)
        }
    }
}
