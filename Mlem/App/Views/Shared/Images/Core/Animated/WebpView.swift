//
//  WebpView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-06.
//

import SDWebImageSwiftUI
import SDWebImage
import SwiftUI

struct WebpView: View {
    @Environment(MediaControlState.self) var controlState
    
    let data: Data
    
    @State var player: SDAnimatedImagePlayer?
    
    var timer = Timer.publish(every: 0.02, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        AnimatedImage(
            data: data,
            isAnimating: Binding(
                get: { controlState.animating },
                set: { controlState.animating = $0 }
            )
        )
        .resizable()
        // https://github.com/SDWebImage/SDWebImageSwiftUI/issues/114#issuecomment-636737317
        .onViewCreate { view, _ in
            view.autoPlayAnimatedImage = controlState.animating
        }
        .onViewUpdate { view, _ in
            if self.player == nil, let viewPlayer = view.player {
                DispatchQueue.main.async {
                    self.player = viewPlayer
                }
            }
        }
        .onChange(of: controlState.scrubTarget) {
            guard let player else {
                return
            }
            if let target = controlState.scrubTarget {
                controlState.animating = false
                player.seekToFrame(
                    at: .init((target * CGFloat(player.totalFrameCount)).rounded()),
                    loopCount: 0
                )
            } else {
                controlState.animating = true
            }
        }
        .onReceive(timer) { _ in
            if let player {
                controlState.playbackPosition = CGFloat(player.currentFrameIndex) / CGFloat(player.totalFrameCount)
            }
        }
    }
}
