//
//  NewMediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

struct NewMediaView: View {
    @State var loader: MediaLoader
    @State var playing: Bool
    
    let aspectRatio_: CGSize?
    var aspectRatio: CGSize { aspectRatio_ ?? loader.mediaType.image.validSize(fallback: .init(width: 4, height: 3)) }
    let contentMode: ContentMode

    /// - Parameters:
    ///   - url: url of the media to render
    ///   - playImmediately: true if animated media should play without user interaction
    ///   - internalLayout: parameters for how the image should be scaled **within** its parent frame
    init(url: URL?,
         playImmediately: Bool = false,
         internalLayout: (aspectRatio: CGSize?, contentMode: ContentMode) = (nil, .fit)
    ) {
        self._loader = .init(wrappedValue: .init(url: url))
        self._playing = .init(wrappedValue: playImmediately)
        self.aspectRatio_ = internalLayout.aspectRatio
        self.contentMode = internalLayout.contentMode
    }
    
    var body: some View {
        if loader.mediaType.isAnimated {
            image
                .overlay {
                    // overlay to prevent visual hitch when swapping views and to implicitly preserve frame/cropping
                    if playing {
                        animatedContent
                            .background {
                                ProgressView()
                            }
                    }
                }
        } else {
            image
        }
    }
    
    var image: some View {
        // https://alejandromp.com/development/blog/image-aspectratio-without-frames/
        Image(uiImage: loader.mediaType.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipped()
    }
    
    @ViewBuilder
    var animatedContent: some View {
        switch loader.mediaType {
        case let .video(_, animated):
            VideoView(asset: animated)
        case let .gif(_, animated):
            GifView(data: animated)
        case let .webp(_, animated):
            WebpView(data: animated)
        default:
            EmptyView()
        }
    }
}
