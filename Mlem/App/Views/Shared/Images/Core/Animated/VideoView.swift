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
    
    init(asset: AVAsset) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
        } catch {
            print(error)
        }
        player = .init(playerItem: .init(asset: asset))
        player.isMuted = true
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.play()
            }
    }
}
