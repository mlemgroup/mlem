//
//  MediaControlState.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-05.
//

import Observation

@Observable
class MediaControlState {
    /// True if the media, if animated, should be playing
    var animating: Bool
    
    /// True if the media should animate, false to suppress animation
    var animationEnabled: Bool
    
    /// True if the media, if audio available, should not play audio
    var muted: Bool
    
    /// True if embedded video controls should be enabled, false otherwise
    let embedControls: Bool
    
    /// True if the media is animated.
    /// - Note: This must be set by MediaView after the media type resolves
    var animationAvailable: Bool = false
    
    /// True when the media has an audio track, false otherwise.
    /// - Note: This must be set by the relevant nested media view once it has extracted audio data
    var audioAvailable: Bool
    
    /// Current loading state of the media
    var loading: MediaLoadingState?
    
    /// Creates a new MediaControlState
    /// - Parameters:
    ///   - animating: true if the media, if animated, should start animating immediately, false otherwise
    ///   - animationEnabled: true if the media should animate at all, false otherwise
    ///   - muted: true if the media should be muted, false otherwise. Defaults to Settings.main.muteVideos.
    ///   - displayMode: whether the media is rendered inline or through the image viewer
    ///   - audioAvailable: true if the media has an audio track, false otherwise. Defaults to false.
    init(
        animating: Bool,
        animationEnabled: Bool = true,
        muted: Bool? = nil,
        embedControls: Bool,
        audioAvailable: Bool = false
    ) {
        self.animating = animating
        self.animationEnabled = animationEnabled
        self.muted = muted ?? Settings.main.muteVideos
        self.embedControls = embedControls
        self.audioAvailable = audioAvailable
    }
}
