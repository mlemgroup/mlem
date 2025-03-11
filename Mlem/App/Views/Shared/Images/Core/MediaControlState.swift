//
//  MediaControlState.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-05.
//

import Observation

enum MediaOverlay {
    case controls, nsfw, error
    
    static var all: Set<MediaOverlay> { [.controls, .nsfw, .error] }
}

@Observable
class MediaControlState {
    
    // TODO: optional; if not present, don't show overlay
    /// True if the media should be blurred, false otherwise
    var blurred: Bool
    
    /// True if the media, if animated, should be playing
    var animating: Bool
    
    /// True if the media should animate, false to suppress animation
    var enableAnimation: Bool
    
    /// True if the media, if audio available, should not play audio
    var muted: Bool
    
    /// Which overlays should be enabled
    let overlays: Set<MediaOverlay>
    
    /// True if the media is animated.
    /// - Note: This must be set by MediaView after the media type resolves
    var animationAvailable: Bool = false
    
    /// True when the media has an audio track, false otherwise.
    /// - Note: This must be set by the relevant nested media view once it has extracted audio data
    var audioAvailable: Bool
    
    /// Current loading state of the media
    var loading: MediaLoadingState?
    
    var enableNsfwOverlay: Bool { overlays.contains(.nsfw) }
    var enableControlOverlay: Bool { overlays.contains(.controls) }
    var enableErrorOverlay: Bool { overlays.contains(.error) }
    
    /// Creates a new MediaControlState
    /// - Parameters:
    ///   - blurred: true if the media should be blurred
    ///   - animating: true if the media, if animated, should start animating immediately, false otherwise
    ///   - enableAnimation: true if the media should animate at all, false otherwise
    ///   - muted: true if the media should be muted, false otherwise. Defaults to Settings.main.muteVideos.
    ///   - audioAvailable: true if the media has an audio track, false otherwise. Defaults to false.
    ///   - enableControls: true if control overlays (NSFW blur, media controls) should be enabled, false otherwise
    init(
        blurred: Bool,
        animating: Bool,
        overlays: Set<MediaOverlay>,
        enableAnimation: Bool = true,
        muted: Bool? = nil,
        audioAvailable: Bool = false
    ) {
        self.blurred = blurred
        self.animating = animating
        self.overlays = overlays
        self.enableAnimation = enableAnimation
        self.muted = muted ?? Settings.main.muteVideos
        self.audioAvailable = audioAvailable
    }
}
