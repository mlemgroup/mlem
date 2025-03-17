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
    
    @State var duration: CMTime?
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
                    self.duration = try await asset.load(.duration)
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
            .onChange(of: controlState.scrubTarget) {
                guard let duration, let playerItem = player.currentItem else {
                    assertionFailure("Duration or playerItem not present")
                    return
                }
                if let target = controlState.scrubTarget {
                    controlState.animating = false
                    playerItem.seek(
                        to: .init(seconds: target * duration.seconds, preferredTimescale: duration.timescale),
                        toleranceBefore: CMTime.zero,
                        toleranceAfter: CMTime.zero,
                        completionHandler: nil
                    )
                } else {
                    controlState.animating = true
                }
            }
            .onReceive(timer) { _ in
                if let duration, let playerItem = player.currentItem {
                    let currentTime = playerItem.currentTime().seconds
                    controlState.playbackPosition = currentTime / duration.seconds
                }
            }
    }
}
