//
//  MediaControlState.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-05.
//

import Foundation
import Observation

@Observable
public class MediaControlState {
    
    public var url: URL?
    
    /// True if the media should be blurred, false otherwise
    public var blurred: Bool
    
    /// True if the media, if animated, should be playing
    public var animating: Bool
    
    /// True if the media, if animated, should autoplay; this is the initial value of `animating`
    public let autoplay: Bool
    
    /// True if the media should animate, false to suppress animation
    public var enableAnimation: Bool
    
    /// True if the media, if audio available, should not play audio
    public var muted: Bool
    
    /// Target playback position of animated media
    public var scrubTarget: CGFloat?
    
    /// True if the media is in a context where scrubbing is possible. Used to determine whether to aggressively
    /// load image data into memory to improve scrubbing performance.
    /// - Warning: This does NOT enable any form of scrubbing control! It only informs the underlying view whether to prepare
    /// appropriately for scrubbing.
    var scrubbingAvailable: Bool
    
    /// True if the media is animated.
    /// - Note: This must be set by MediaView after the media type resolves
    public var animationAvailable: Bool = false
    
    /// True when the media has an audio track, false otherwise.
    /// - Note: This must be set by the relevant nested media view once it has extracted audio data
    public var audioAvailable: Bool = false
    
    /// Current playback position of animated media
    /// - Note: This should only be set by the nested media view; to scrub, update scrubTarget
    public var playbackPosition: CGFloat = 0
    
    /// Duration of animated media
    /// - Note: This should only be set by the nested media view
    public var duration: TimeInterval?
    
    /// Current loading state of the media
    public var loading: MediaLoadingState?
    
    public var mediaLockId: UUID?
    
    public var playbackReadouts: (position: String, duration: String)? {
        guard let duration else { return nil }
        return (position: minuteSecondString(from: playbackPosition * duration), duration: minuteSecondString(from: duration))
    }
    
    public var canAnimate: Bool { animationAvailable && enableAnimation }
    
    /// Creates a new MediaControlState
    /// - Parameters:
    ///   - url: URL of the media
    ///   - blurred: true if the media should be blurred
    ///   - animating: true if animated media should currently be animating. If initialized with `true`, animated media will autoplay.
    ///   - overlays: set of overlays to use
    ///   - enableAnimation: true if the media should animate at all, false otherwise
    ///   - muted: true if the media should be muted, false otherwise. Defaults to Settings.main.muteVideos.
    ///   - audioAvailable: true if the media has an audio track, false otherwise. Defaults to false.
    public init(
        url: URL?,
        blurred: Bool,
        animating: Bool,
        enableAnimation: Bool = true,
        muted: Bool,
        scrubbingAvailable: Bool = false
    ) {
        self.url = url
        self.blurred = blurred
        self.animating = animating
        self.autoplay = animating
        self.enableAnimation = enableAnimation
        self.muted = muted
        self.scrubbingAvailable = scrubbingAvailable
    }
    
    private func minuteSecondString(from timeInterval: TimeInterval) -> String {
        Duration.seconds(timeInterval).formatted(.time(pattern: .minuteSecond))
    }
}
