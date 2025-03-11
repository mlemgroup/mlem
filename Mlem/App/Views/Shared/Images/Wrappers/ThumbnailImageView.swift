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
    
    @State var mediaControlState: MediaControlState
    @State var quickLookUrl: URL?
    
    let post: any Post1Providing
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
        self.size = size
        self.frame = frame
        
        self._mediaControlState = .init(wrappedValue: .init(
            blurred: blurred,
            animating: false,
            overlays: .init(),
            enableAnimation: false
        ))
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
        MediaView(
            url: url,
            size: frame,
            controlState: $mediaControlState,
            aspectRatioBounds: .absoluteSquare,
            contentMode: .fill,
            cornerRadius: size == .tile ? 0 : Constants.main.smallItemCornerRadius,
            fallback: post.imageFallback,
            enableImageViewer: post.type.isMedia
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
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            navigation.shareInfo = .init(url: fileUrl)
        }
    }
}
