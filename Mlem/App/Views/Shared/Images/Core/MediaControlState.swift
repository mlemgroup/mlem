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
    
    init(animating: Bool, muted: Bool, displayMode: MediaDisplayMode, audioAvailable: Bool = false) {
        self.animating = animating
        self.muted = muted
        self.displayMode = displayMode
        self.audioAvailable = audioAvailable
    }
}
