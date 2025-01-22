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
    let player: AVQueuePlayer
    let playerLooper: AVPlayerLooper
    
    /// Controls the video's animation (true for playing). Defaults to false; video is automatically started once audio is resolved
    @State var animating: Bool = false
    
    /// Controls the video's audio state (true for muted).
    @State var muted: Bool
    
    /// Whether the video has an audio track. Set post-appearance since this is asynchronously computed.
    @State var audioAvailable: Bool = false
    
    /// Observer to track external modifications to the `isMuted` status of the player.
    @State var observer: NSKeyValueObservation?

    /// Whether this is the first time this view has appeared
    @State var isFirstAppearance: Bool = true
    
    init(asset: AVAsset) {
        // set up AVQueuePlayer and AVPlayerLooper to loop the video
        let playerItem: AVPlayerItem = .init(asset: asset)
        
        self.player = .init(playerItem: playerItem)
        self.playerLooper = .init(player: player, templateItem: playerItem)

        @Setting(\.muteVideos) var muteVideos
        player.isMuted = muteVideos
        self._muted = .init(wrappedValue: muteVideos)
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .onDisappear {
                observer = nil
            }
            .onAppear {
                guard observer == nil else { return }
                
                // audio is automatically turned on if the user modifies their volume. This listens to that event and updates muted to match.
                observer = player.observe(\.isMuted, options: [.new]) { _, value in
                    if let newValue = value.newValue, newValue != muted {
                        muted = newValue
                    }
                }
            }
            .task {
                // parse whether the video has audio or not before playing so we can appropriately display audio controls
                do {
                    audioAvailable = try await player.isAudioAvailable() ?? false
                } catch {
                    handleError(error)
                }
                
                // if parse fails, assume no audio and play anyway
                if isFirstAppearance {
                    animating = true
                    isFirstAppearance = false
                }
            }
            .onChange(of: animating, initial: false) {
                if animating {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onChange(of: muted, initial: false) {
                if player.isMuted != muted {
                    player.isMuted = muted
                }
            }
            .withAnimationControls(animating: $animating, muted: audioAvailable ? $muted : nil)
    }
}
