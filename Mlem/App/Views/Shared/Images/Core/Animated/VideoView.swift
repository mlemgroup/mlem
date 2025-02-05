//
//  VideoView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-23.
//

import AVFoundation
import AVKit
import NukeVideo
import SwiftUI

struct VideoView: View {
    @Environment(MediaControlState.self) var controlState
    
    let player: AVQueuePlayer
    let playerLooper: AVPlayerLooper
    
    /// Whether this is the first time this view has appeared
    @State var isFirstAppearance: Bool = true
    
    init(asset: AVAsset) {
        // set up AVQueuePlayer and AVPlayerLooper to loop the video
        let playerItem: AVPlayerItem = .init(asset: asset)
        
        self.player = .init(playerItem: playerItem)
        self.playerLooper = .init(player: player, templateItem: playerItem)

        player.volume = Settings.main.muteVideos ? 0 : 1
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .task {
                // parse whether the video has audio or not before playing so we can appropriately display audio controls
                do {
                    controlState.audioAvailable = try await player.isAudioAvailable() ?? false
                } catch {
                    handleError(error)
                }
                
                // if parse fails, assume no audio and play anyway
                if isFirstAppearance {
                    controlState.animating = true
                    isFirstAppearance = false
                }
            }
            .onChange(of: controlState.animating) {
                if controlState.animating {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onChange(of: controlState.muted, initial: true) {
                player.volume = controlState.muted ? 0 : 1
            }
            .withAnimationControls()
    }
}
