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
import Media

struct ThumbnailImageView: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.openURL) var openURL
    
    @Setting(\.a11y_websiteThumbnailIcon) var websiteThumbnailIcon
    @Setting(\.post_size) var postSize
    
    @State var mediaControlState: MediaControlState
    @State var quickLookUrl: URL?
    
    let post: Post
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
    
    var onTapActions: (() -> Void)? {
        switch post.type {
        case .media, .embedded:
            { post.updateRead(true) }
        case let .link(link):
            {
                post.updateRead(true)
                openURL(link.content)
            }
        default:
            nil
        }
    }
    
    init(
        post: Post,
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
            enableAnimation: false,
            muted: Settings.get(\.behavior_muteVideos)
        ))
    }
    
    var body: some View {
        content
            .overlay {
                if websiteThumbnailIcon, case .link = post.type {
                    Image(icon: .general.browser)
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
            enableContextMenu: post.type.isMedia,
            enableImageViewer: post.type.isMedia,
            onTapActions: onTapActions
        )
        .overlay {
            if mediaControlState.animationAvailable {
                PlayButton(postSize: postSize)
            }
        }
    }
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            navigation.model?.shareInfo = .init(url: fileUrl)
        }
    }
}
