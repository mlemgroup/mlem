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
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.openURL) var openURL
    
    @Setting(\.websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.postSize) var postSize
    
    @State var mediaControlState: MediaControlState = .init(
        animating: false,
        animationEnabled: false,
        embedControls: false
    )
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
        content
            .overlay {
                if websiteThumbnailIcon, case .link = post.type {
                    Image(systemName: Icons.browser)
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.white)
                        .background(.ultraThinMaterial, in: .circle)
                        .padding(4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
            MediaView(
                url: url,
                size: .init(width: 10, height: 10),
                controlState: $mediaControlState,
                aspectRatioBounds: .absoluteSquare,
                contentMode: .fill,
                cornerRadius: Constants.main.smallItemCornerRadius,
                enableImageViewer: post.type.isMedia,
                enableNsfwBlur: blurred,
                playImmediately: false
            ) {
                post.markRead()
                if case let .link(link) = post.type {
                    openURL(link.content)
                }
            }
            .overlay {
                if mediaControlState.animationAvailable {
                    PlayButton(postSize: postSize)
                }
            }
        }
//        } else {
//            Image(systemName: post.placeholderImageName)
//                .font(.title)
//                .frame(width: frame.width, height: frame.width)
//                .foregroundStyle(.themedSecondary)
//                .background(.themedThumbnailBackground)
//                .clipShape(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius))
//                .overlay(RoundedRectangle(cornerRadius: Constants.main.smallItemCornerRadius)
//                    .stroke(.themedSecondaryBackground, lineWidth: 1))
//        }
    }
    
    @ViewBuilder
    var tileContent: some View {
        if let url {
            FixedImageView(
                url: url,
                size: frame,
                fallback: .image,
                showProgress: true,
                blurred: blurred && mediaControlState.loading == .done
            )
        } else {
            Image(systemName: post.placeholderImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 50)
                .padding(4)
                .foregroundStyle(.themedTertiary)
        }
    }
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            navigation.shareInfo = .init(url: fileUrl)
        }
    }
}
