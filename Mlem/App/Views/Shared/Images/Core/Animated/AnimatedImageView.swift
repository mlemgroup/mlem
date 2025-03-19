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
    
    @State var duration: CGFloat?
    
    var body: some View {
        UIAnimatedImageView(
            data: data,
            scrubTarget: Binding(
                get: { controlState.scrubTarget },
                set: { _ in }
            )
        )
    }
}

private struct UIAnimatedImageView: UIViewRepresentable {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    @Binding var scrubTarget: CGFloat?
    
    @State var player: SDAnimatedImagePlayer?
    @State var observer: NSKeyValueObservation?
    
    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = controlState.animating
        
        guard let animatedImage = SDAnimatedImage(data: data) else {
            handleError(MlemError.mediaError("Could not create animated image"))
            return imageView
        }
        
        // TODO: only if scrubbing enabled
        Task {
            // loads all frames, which enables smooth backwards scrubbing
            animatedImage.preloadAllFrames()
        }
        
        // compute real time duration
        Task {
            var total: Double = 0
            for index in (0..<animatedImage.animatedImageFrameCount) {
                total += animatedImage.animatedImageDuration(at: index)
            }
            print("DEBUG runtime: \(total)")
        }
        
        // set up animation info with frame count and observation to update current frame
        DispatchQueue.main.async {
            guard let player = imageView.player else {
                assertionFailure("ImageView had nil player")
                return
            }
            print("DEBUG total frames: \(player.totalFrameCount)")
            observer = player.observe(\.currentFrameIndex) { player, _ in
                controlState.playbackPosition = CGFloat(player.currentFrameIndex) / CGFloat(player.totalFrameCount)
            }
            self.player = player
        }
        
        imageView.image = animatedImage
        
        // fit parent view
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return imageView
    }
    
    func updateUIView(_ uiView: SDAnimatedImageView, context: Context) {
        guard let player else {
            return
        }
    
        if let scrubTarget {
            if player.isPlaying {
                player.pausePlaying()
            }
            
            player.seekToFrame(
                at: .init((scrubTarget * CGFloat(player.totalFrameCount)).rounded()),
                loopCount: 0
            )
        } else if controlState.animating != player.isPlaying {
            if controlState.animating {
                player.startPlaying()
            } else {
                player.pausePlaying()
            }
        }
    }
}
