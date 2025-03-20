//
//  WebpView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SDWebImage
import SwiftUI

struct AnimatedImageView: UIViewRepresentable {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    @State var player: SDAnimatedImagePlayer?
    @State var observer: NSKeyValueObservation?
    
    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = controlState.animating
        
        guard let animatedImage = SDAnimatedImage(data: data) else {
            handleError(MlemError.mediaError("Could not create animated image"))
            return imageView
        }
        
        if controlState.scrubbingAvailable {
            // loads all frames, which enables smooth backwards scrubbing
            Task {
                animatedImage.preloadAllFrames()
            }
        }
        
        // compute real time duration
        Task {
            var total: TimeInterval = 0
            for index in (0..<animatedImage.animatedImageFrameCount) {
                total += animatedImage.animatedImageDuration(at: index)
            }
            controlState.duration = total
        }
        
        // set up player with observation to update controlState.playbackPosition
        DispatchQueue.main.async {
            guard let player = imageView.player else {
                assertionFailure("ImageView had nil player")
                return
            }
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
    
        if let scrubTarget = controlState.scrubTarget {
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
