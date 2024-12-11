//
//  AVPlayer+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-09.
//
//  From https://stackoverflow.com/questions/11704322/how-to-check-if-avplayer-has-video-or-just-audio

import AVFoundation

extension AVPlayer {
    func isAudioAvailable() async throws -> Bool? {
        return try await self.currentItem?.asset.loadTracks(withMediaType: .audio).count != 0
    }
}
