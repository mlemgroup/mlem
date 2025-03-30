//
//  MediaControlState.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-05.
//

import Foundation
import Observation

@Observable
class MediaControlState {
    /// True if the media should be blurred, false otherwise
    var blurred: Bool
    
    /// True if the media, if animated, should be playing
    var animating: Bool
    
    /// True if the media, if animated, should autoplay; this is the initial value of `animating`
    let autoplay: Bool
    
    /// True if the media should animate, false to suppress animation
    var enableAnimation: Bool
    
    /// True if the media, if audio available, should not play audio
    var muted: Bool
    
    /// Which overlays should be enabled
    let overlays: Set<MediaView.Overlay>
    
    /// Target playback position of animated media
    var scrubTarget: CGFloat?
    
    /// True if the media is in a context where scrubbing is possible. Used to determine whether to aggressively
    /// load image data into memory to improve scrubbing performance.
    /// - Warning: This does NOT enable any form of scrubbing control! It only informs the underlying view whether to prepare
    /// appropriately for scrubbing.
    var scrubbingAvailable: Bool
    
    /// True if the media is animated.
    /// - Note: This must be set by MediaView after the media type resolves
    var animationAvailable: Bool = false
    
    /// True when the media has an audio track, false otherwise.
    /// - Note: This must be set by the relevant nested media view once it has extracted audio data
    var audioAvailable: Bool = false
    
    /// Current playback position of animated media
    /// - Note: This should only be set by the nested media view; to scrub, update scrubTarget
    var playbackPosition: CGFloat = 0
    
    /// Duration of animated media
    /// - Note: This should only be set by the nested media view
    var duration: TimeInterval?
    
    /// Current loading state of the media
    var loading: MediaLoadingState?
    
    var enableNsfwOverlay: Bool { overlays.contains(.nsfw) }
    var enableControlOverlay: Bool { overlays.contains(.controls) }
    var enableErrorOverlay: Bool { overlays.contains(.error) }
    
    var playbackReadouts: (position: String, duration: String)? {
        guard let duration else { return nil }
        return (position: minuteSecondString(from: playbackPosition * duration), duration: minuteSecondString(from: duration))
    }
    
    var url: URL?
    
    /// Creates a new MediaControlState
    /// - Parameters:
    ///   - blurred: true if the media should be blurred
    ///   - animating: true if animated media should currently be animating. If initialized with `true`, animated media will autoplay.
    ///   - overlays: set of overlays to use
    ///   - enableAnimation: true if the media should animate at all, false otherwise
    ///   - muted: true if the media should be muted, false otherwise. Defaults to Settings.main.muteVideos.
    ///   - audioAvailable: true if the media has an audio track, false otherwise. Defaults to false.
    init(
        blurred: Bool,
        animating: Bool,
        overlays: Set<MediaView.Overlay>,
        enableAnimation: Bool = true,
        muted: Bool? = nil,
        scrubbingAvailable: Bool = false
    ) {
        self.blurred = blurred
        self.animating = animating
        self.autoplay = animating
        self.overlays = overlays
        self.enableAnimation = enableAnimation
        self.muted = muted ?? Settings.main.muteVideos
        self.scrubbingAvailable = scrubbingAvailable
    }
    
    private func minuteSecondString(from timeInterval: TimeInterval) -> String {
        Duration.seconds(timeInterval).formatted(.time(pattern: .minuteSecond))
    }
}
