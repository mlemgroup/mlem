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
    @State private var animationInfo: AnimationInfo = .init()
    
    var body: some View {
        UIAnimatedImageView(
            data: data,
            animating: Binding(
                get: { controlState.animating },
                set: { _ in }
            ),
            scrubTarget: Binding(
                get: { controlState.scrubTarget },
                set: { _ in }
            ),
            animationInfo: animationInfo
        )
        .onChange(of: animationInfo.currentFrame) {
            controlState.playbackPosition = animationInfo.progress
        }
    }
}

private struct UIAnimatedImageView: UIViewRepresentable {
    let data: Data
    
    @Binding var animating: Bool
    @Binding var scrubTarget: CGFloat?
    var animationInfo: AnimationInfo
    
    @State var player: SDAnimatedImagePlayer?
    @State var observer: NSKeyValueObservation?
    
    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = animating
        
        guard let animatedImage = SDAnimatedImage(data: data) else {
            handleError(MlemError.mediaError("Could not create animated image"))
            return imageView
        }
        
        // preload all frames to improve scrubbing performance
        Task {
            animatedImage.preloadAllFrames()
        }
        
        // compute real time duration
        Task {
            var total: Double = 0
            for index in (0..<animatedImage.animatedImageFrameCount) {
                total += animatedImage.animatedImageDuration(at: index)
            }
            animationInfo.duration = total
        }
        
        // set up animation info with frame count and observation to update current frame
        DispatchQueue.main.async {
            guard let player = imageView.player else {
                assertionFailure("ImageView had nil player")
                return
            }
            animationInfo.totalFrames = Int(player.totalFrameCount)
            observer = player.observe(\.currentFrameIndex) { _, _ in
                print("DEBUG \(player.currentFrameIndex)")
                // animationInfo.currentFrame = Int(player.currentFrameIndex)
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
                player.stopPlaying()
            }
            
            // preload all frames of the image to improve scrubbing performance
            if let animatedImage = uiView.image as? SDAnimatedImage,
               !animatedImage.isAllFramesLoaded {
                print("DEBUG loading all frames")
                Task {
                    animatedImage.preloadAllFrames()
                }
            }
            
            player.seekToFrame(
                at: .init((scrubTarget * CGFloat(player.totalFrameCount)).rounded()),
                loopCount: 0
            )
        } else if animating != player.isPlaying {
            if animating {
                player.startPlaying()
            } else {
                player.stopPlaying()
            }
        }
    }
}

@Observable
private class AnimationInfo {
    var duration: CGFloat?
    var totalFrames: Int?
    var currentFrame: Int?
    
    var progress: CGFloat {
        guard let currentFrame, let totalFrames else { return 0 }
        return CGFloat(currentFrame) / CGFloat(totalFrames)
    }
}
