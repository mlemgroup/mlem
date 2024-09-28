//
//  MediaView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-26.
//

import SDWebImageSwiftUI
import SwiftUI
import UIKit

struct MediaView: View {
    let media: MediaType
    
    @Binding var playing: Bool
    
    var body: some View {
        if media.isAnimated {
            image
                .overlay {
                    // overlay to prevent visual hitch when swapping views and to implicitly preserve frame/cropping
                    // TODO: tap should play/pause
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
        Image(uiImage: media.image)
            .resizable()
            .aspectRatio(media.image.validSize(fallback: .init(width: 4, height: 3)), contentMode: .fit)
    }
    
    @ViewBuilder
    var animatedContent: some View {
        switch media {
        case let .video(_, animated):
            VideoView(asset: animated)
        case let .gif(_, animated):
            GifView(data: animated)
        case let .webp(_, animated):
            AnimatedImage(data: animated)
                .resizable()
        default:
            EmptyView()
        }
    }
}

private extension UIImage {
    func validSize(fallback: CGSize) -> CGSize {
        size == .zero ? fallback : size
    }
}
