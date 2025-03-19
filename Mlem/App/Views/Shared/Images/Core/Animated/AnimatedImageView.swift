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
    
    @State var duration: CGFloat?
    
    var body: some View {
        UIAnimatedImageView(
            data: data,
            animating: Binding(
                get: { controlState.animating },
                set: { controlState.animating = $0 }
            ),
            scrubTarget: Binding(
                get: { controlState.scrubTarget },
                set: { _ in }
            ),
            duration: $duration
        )
        .onChange(of: duration) {
            print("DEBUG duration: \(duration)")
        }
    }
}

private struct UIAnimatedImageView: UIViewRepresentable {
    let data: Data
    
    @Binding var animating: Bool
    @Binding var scrubTarget: CGFloat?
    @Binding var duration: CGFloat?
    
    @State var player: SDAnimatedImagePlayer?
    
    func makeUIView(context: Context) -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.autoPlayAnimatedImage = animating
        
        guard let animatedImage = SDAnimatedImage(data: data) else {
            handleError(MlemError.mediaError("Could not create animated image"))
            return imageView
        }
        
        Task {
            var total: Double = 0
            for index in (0..<animatedImage.animatedImageFrameCount) {
                total += animatedImage.animatedImageDuration(at: index)
            }
            duration = total
        }
        
        DispatchQueue.main.async {
            guard let player = imageView.player else {
                assertionFailure("ImageView had nil player")
                return
            }
            self.player = player
        }
        
        imageView.image = animatedImage
        
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return imageView
    }
    
    func updateUIView(_ uiView: SDAnimatedImageView, context: Context) {
        guard let player else {
            return
        }
        
        if animating != player.isPlaying {
            if animating {
                player.startPlaying()
            } else {
                player.stopPlaying()
            }
        }
        
        if let scrubTarget {
            // preload all frames of the image to improve scrubbing performance
            if let animatedImage = uiView.image as? SDAnimatedImage,
               !animatedImage.isAllFramesLoaded {
                Task {
                    animatedImage.preloadAllFrames()
                }
            }
            
            player.seekToFrame(
                at: .init((scrubTarget * CGFloat(player.totalFrameCount)).rounded()),
                loopCount: 0
            )
        }
    }
}
