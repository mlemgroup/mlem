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
    
    @State var duration: CGFloat?
    var timer = Timer.publish(every: 0.02, on: .main, in: .common)
        .autoconnect()
    
    init(asset: AVAsset) {
        // set up AVQueuePlayer and AVPlayerLooper to loop the video
        let playerItem: AVPlayerItem = .init(asset: asset)
        
        let player: AVQueuePlayer = .init(playerItem: playerItem)
        self.player = player
        self.playerLooper = .init(player: player, templateItem: playerItem)
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
            }
            .task {
                do {
                    guard let asset = player.currentItem?.asset else {
                        assertionFailure("Could not find AVAsset")
                        return
                    }
                    self.duration = try await asset.load(.duration).seconds
                    print("DEBUG new duration: \(self.duration)")
                } catch {
                    handleError(error)
                }
            }
            .onChange(of: controlState.animating, initial: true) {
                if controlState.animating {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onChange(of: controlState.muted, initial: true) {
                player.volume = controlState.muted ? 0 : 1
            }
            .onReceive(timer) { _ in
                if let duration, let playerItem = player.currentItem, controlState.scrubTarget == nil {
                    let currentTime = playerItem.currentTime().seconds
                    print("DEBUG \(currentTime) / \(duration)")
                    controlState.playbackPosition = currentTime / duration
                }
            }
    }
}
