//
//  CoreMediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-04-20.
//

import SwiftUI

/// Struct to actually render the media.
/// This is declared as its own struct to prevent state updates from the parent view causing unwanted behavior.
public struct CoreMediaView: View {
    @Environment(MediaControlState.self) var controlState
    
    let media: MediaType
    let aspectRatio: CGSize
    let contentMode: ContentMode
    
    let mediaLockId: UUID
    
    public init(media: MediaType, aspectRatio: CGSize, contentMode: ContentMode, mediaLockId: UUID) {
        self.media = media
        self.aspectRatio = aspectRatio
        self.contentMode = contentMode
        self.mediaLockId = mediaLockId
    }
    
    var uiImage: UIImage { media.image }

    public var body: some View {
        // WARNING: the combination of .aspectRatio and .frame modifiers in this view is very precise and
        // breaks easily. If you have to modify it, be sure to thoroughly regression test!
        // More info here: https://alejandromp.com/development/blog/image-aspectratio-without-frames/
        Group {
            if contentMode == .fit {
                content
            } else if contentMode == .fill {
                content
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity
                    )
            }
        }
        .aspectRatio(aspectRatio, contentMode: contentMode)
        .allowsHitTesting(false)
    }
    
    @ViewBuilder
    var content: some View {
        if controlState.canAnimate, media.isAnimated, controlState.mediaLockId == mediaLockId {
            animatedContent
        } else {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        }
    }
    
    @ViewBuilder
    var animatedContent: some View {
        Group {
            switch media {
            case let .video(_, animated):
                VideoView(asset: animated)
            case let .animated(_, animated):
                AnimatedImageView(data: animated)
            default:
                EmptyView()
            }
        }
        .aspectRatio(uiImage.size, contentMode: contentMode)
    }
}
