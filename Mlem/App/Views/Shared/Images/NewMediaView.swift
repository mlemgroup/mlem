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
    
    var uiImage: UIImage { loader.mediaType.image }

    // TODO: update verticalAspectRatioBounds to aspectRatio, include aspectBounding enum (.vertical, .horizontal, .absolute)
    
    /// - Parameters:
    ///   - url: url of the media to render
    ///   - playImmediately: true if animated media should play without user interaction
    ///   - verticalAspectRatioBounds: tallest allowable aspect ratio
    ///   - contentMode: how content should be resized to fit within its bounds
    init(url: URL,
         playImmediately: Bool = false,
         verticalAspectRatioBounds: CGSize? = nil,
         contentMode: ContentMode = .fit
    ) {
        self._loader = .init(wrappedValue: .init(url: url))
        self._playing = .init(wrappedValue: playImmediately)
        self.aspectRatio_ = verticalAspectRatioBounds
        self.contentMode = contentMode
    }
    
    var body: some View {
        content
            .onAppear {
                Task {
                    await loader.load()
                }
            } // TEMP BELOW THIS POINT
            .overlay {
                if loader.loading != .done {
                    ProgressView()
                }
            }
    }
    
    @ViewBuilder
    var content: some View {
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
        // adapted from https://alejandromp.com/development/blog/image-aspectratio-without-frames/
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                minHeight: 0,
                maxHeight: .infinity
            )
            .aspectRatio(uiImage.verticallyBoundedAspectRatio(bounds: aspectRatio), contentMode: contentMode)
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

extension UIImage {
    /// Returns this image's aspect ratio or the given bounds, whichever is shorter
    func verticallyBoundedAspectRatio(bounds: CGSize) -> CGSize {
        guard size != .zero else { return bounds }

        if size.height / size.width > bounds.height / bounds.width {
            return bounds
        }
        
        return size
    }
}
