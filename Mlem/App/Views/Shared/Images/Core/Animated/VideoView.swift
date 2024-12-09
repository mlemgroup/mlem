//
//  VideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-23.
//

import AVFoundation
import NukeVideo
import SwiftUI
import AVKit

struct VideoView: View {
    let player: AVPlayer
    
    @State var animating: Bool = true
    @State var soundOn: Bool
    
    init(asset: AVAsset) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print(error)
        }
        player = .init(playerItem: .init(asset: asset))
        
        player.isMuted = false
        self._soundOn = .init(wrappedValue: true)
        
        player.play()
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .onChange(of: animating, initial: false) {
                if animating {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onChange(of: soundOn, initial: false) {
                player.isMuted = !soundOn
            }
            .withAnimationControls(animating: $animating, soundOn: $soundOn)
    }
}
