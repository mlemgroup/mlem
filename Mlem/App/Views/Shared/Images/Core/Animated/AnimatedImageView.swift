//
//  WebpView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SDWebImage
import SwiftUI

struct AnimatedImageView: View {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    var timer = Timer.publish(every: 0.02, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        UIAnimatedImageView(data: data, animating: Binding(
            get: { controlState.animating },
            set: { controlState.animating = $0 }
        ))
    }
}

private struct UIAnimatedImageView: UIViewRepresentable {
    let data: Data
    
    @Binding var animating: Bool
    
    // TODO: maybe in context, need coordinator
    @State var player: SDAnimatedImagePlayer?
    
    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = animating
        
        guard let animatedImage = SDAnimatedImage(data: data) else {
            handleError(MlemError.mediaError("Could not create animated image"))
            return imageView
        }
        animatedImage.preloadAllFrames() // improve backward scrubbing performance
        
        DispatchQueue.main.async {
            assert(imageView.player != nil, "imageView had nil player")
            self.player = imageView.player
        }
        
        imageView.image = animatedImage
        return imageView
    }
    
    func updateUIView(_ uiView: SDAnimatedImageView, context: Context) {
        if animating {
            player?.startPlaying()
        } else {
            player?.stopPlaying()
        }
    }
}
