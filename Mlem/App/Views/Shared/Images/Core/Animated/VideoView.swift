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
    let player: AVQueuePlayer
    let playerLooper: AVPlayerLooper
    
    @State var animating: Bool = false
    @State var muted: Bool
    @State var audioAvailable: Bool = false
    
    init(asset: AVAsset) {
        // set up AVQueuePlayer and AVPlayerLooper to loop the video
        let playerItem: AVPlayerItem = .init(asset: asset)
        player = .init(playerItem: playerItem)
        playerLooper = .init(player: player, templateItem: playerItem)
        
        // set initial audio state to user preference
        @Setting(\.muteVideos) var muteVideos
        player.isMuted = muteVideos
        self._muted = .init(wrappedValue: muteVideos)
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .task {
                // parse whether the video has audio or not before playing so we can appropriately display audio controls
                do {
                    audioAvailable = try await player.isAudioAvailable() ?? false
                } catch {
                    handleError(error)
                }
                
                // if parse fails, assume no audio and play anyway
                animating = true
            }
            .onChange(of: animating, initial: false) {
                if animating {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onChange(of: muted, initial: false) {
                player.isMuted = muted
            }
            .withAnimationControls(animating: $animating, muted: audioAvailable ? $muted : nil)
    }
}
