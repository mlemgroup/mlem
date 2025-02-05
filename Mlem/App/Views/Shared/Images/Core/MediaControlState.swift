//
//  MediaControlState.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-05.
//

import Observation

enum MediaDisplayMode {
    case inline, viewer
}

@Observable
class MediaControlState {
    /// True if the media, if animated, should be playing
    var animating: Bool
    
    /// True if the media, if audio available, should not play audio
    var muted: Bool
    
    /// Whether the media is displayed inline (e.g., in a large post) or in the image viewer
    let displayMode: MediaDisplayMode
    
    /// True when the media has an audio track, false otherwise. This must be set by the child media!
    var audioAvailable: Bool
    
    /// Creates a new MediaControlState
    /// - Parameters:
    ///   - animating: true if the media should be animating immediately, false otherwise
    ///   - muted: true if the media should be muted, false otherwise. Defaults to Settings.main.muteVideos.
    ///   - displayMode: whether the media is rendered inline or through the image viewer
    ///   - audioAvailable: true if the media has an audio track, false otherwise. Defaults to false.
    init(animating: Bool, muted: Bool? = nil, displayMode: MediaDisplayMode, audioAvailable: Bool = false) {
        self.animating = animating
        self.muted = muted ?? Settings.main.muteVideos
        self.displayMode = displayMode
        self.audioAvailable = audioAvailable
    }
}
