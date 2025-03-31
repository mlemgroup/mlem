//
//  ImageViewer.swift
//  Mlem
//
//  Created by Sjmarf on 13/06/2024.
//

import SwiftUI

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
struct ImageViewer: View {
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Setting(\.developerMode) var developerMode
    @Setting(\.zoomSliderLocation) var zoomSliderLocation
    
    let url: URL
    
    let duration: CGFloat = 0.25
    let maxControlOffset: CGFloat = 50
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    
    @State var controlState: MediaControlState = .init(
        blurred: false,
        animating: true,
        overlays: [.error],
        scrubbingAvailable: true
    )
    
    /// Current scale of the ZoomableContainer
    @State var currentScale: CGFloat = 1.0
    
    /// True when the scale indicator should be visible, false otherwise
    @State var scaleDisplayShown: Bool = false
    
    /// Scale when slide-to-zoom gesture started
    @State var dragStartedScale: CGFloat?
    
    /// Tracks slide-to-zoom drag gesture
    @GestureState var scaleDragState: Bool = false
    
    /// Tracks scrub/dismiss drag gesture
    @GestureState var dragState: Bool = false
    
    /// True when the current drag gesture is a scrub, false when dismiss, nil when no gesture
    @State var dragIsScrub: Bool?
    
    /// controlState.playbackPosition when current scrub segment began
    @State var scrubStartedPlaybackPosition: CGFloat?
    
    /// controlState.playbackPosition when current scrub segment began
    @State var scrubSegmentOffset: CGFloat = 0
    
    /// Current scrubbing rate
    @State var scrubRate: CGFloat = 1
    
    /// Hitbox of the playback bar
    @State var playbackBarHitbox: CGRect?
    
    /// True when the image is zoomed in, false otherwise
    @State var isZoomed: Bool = false
    
    /// True when dimissal is in progress, false otherwise
    @State var isDismissing: Bool = false
    
    /// Vertical offset of the viewer
    @State var offset: CGFloat = 0
    
    /// Opacity of the viewer
    @State var opacity: CGFloat = 0
    
    /// Vertical offset for the control overlay
    @State var controlOffset: CGFloat = 0
    
    /// Opacity for the control overlay
    @State var controlOpacity: CGFloat = 1
    
    /// When true, enables tapping to show/hide controls
    @State var enableControlTap: Bool = true
    
    @State var quickLookUrl: URL?
    
    /// Value to show in the top leading scale display (either scrub rate or zoom depending)
    @State var scaleDisplayValue: CGFloat = 1
    
    @State var devToolsShown: Bool = false
    
    /// Whether the controls are currently visible
    var controlsShown: Bool { controlOpacity > 0 }
    
    // -------------------------------------------------------- UNDER CONSTRUCTION
    
    @State var anchor: UnitPoint = .center
    @State var pinchOffset: CGSize = .zero
    @State var targetScale: CGFloat = 1
    
    // --------------------------------------------------------
    
    init(url: URL) {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = components.queryItems?.filter { $0.name != "thumbnail" }
        self.url = components.url!
    }
    
    var body: some View {
        zoomableImage
            .offset(y: offset)
            .background(.black)
            .overlay(controlOverlay)
            .overlay(alignment: .topLeading) {
                scaleDisplay
            }
            .opacity(opacity)
            .onChange(of: isZoomed) {
                if isZoomed {
                    hideControls(withSlide: true)
                } else {
                    showControls(withSlide: true)
                }
            }
            .onTapGesture {
                if enableControlTap {
                    if controlsShown {
                        hideControls()
                    } else {
                        showControls()
                    }
                }
            }
//            .simultaneousGesture(DragGesture(minimumDistance: 1.0)
//                .onChanged { handleDragGesture(value: $0) }
//                .updating($dragState) { _, state, _ in
//                    // this detects cancelled gestures (e.g., if you zoom while dragging)
//                    state = true
//                }
//            )
            .onAppear {
                animateOpacityUpdate(1.0)
            }
            .onChange(of: dragState) {
                handleDragStateChange(dragState)
            }
            .onChange(of: scaleDragState) {
                if !scaleDragState {
                    dragStartedScale = nil
                }
            }
            .onChange(of: scrubRate) {
                if dragIsScrub ?? false { // don't update value if not currently scrubbing
                    scaleDisplayValue = scrubRate
                }
            }
            .onChange(of: currentScale) {
                scaleDisplayValue = currentScale
                isZoomed = currentScale != 1.0
            }
            .onChange(of: scaleDisplayValue) {
                if !scaleDisplayShown {
                    withAnimation(.easeIn(duration: 0.1)) {
                        scaleDisplayShown = true
                    }
                }
                let oldScale: CGFloat = scaleDisplayValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if scaleDisplayValue == oldScale {
                        withAnimation {
                            scaleDisplayShown = false
                        }
                    }
                }
            }
            .quickLookPreview($quickLookUrl)
            .background(ClearBackgroundView())
            .statusBarHidden(!isDismissing)
            .coordinateSpace(name: "ImageViewer")
    }
    
    @ViewBuilder
    var zoomableImage: some View {
        MediaView(url: url, controlState: $controlState)
            .overlay {
                ZoomRecognizer(scale: $currentScale, offset: $pinchOffset)
            }
            .scaleEffect(currentScale)
            .offset(x: pinchOffset.width, y: pinchOffset.height)
    }
    
    func handleDragGesture(value: DragGesture.Value) {
        guard !isZoomed else {
            return
        }
        
        let dragIsScrub = self.dragIsScrub ?? (abs(value.velocity.height) < abs(value.velocity.width))
        self.dragIsScrub = dragIsScrub
        
        if dragIsScrub {
            if controlState.animationAvailable, controlState.enableAnimation {
                handleScrubUpdate(value)
            }
        } else if !isDismissing {
            handleOffsetUpdate(value.translation.height)
        }
    }
    
    func handleDragStateChange(_ newDragState: Bool) {
        guard !isZoomed else { return }
        
        if newDragState {
            // drag gesture conflicts with control tap, so we disable it for a brief window after detecting a drag
            enableControlTap = false
        } else {
            guard let scrubbing = dragIsScrub else {
                // assertionFailure("dragGesture ended but dragIsScrub not defined")
                return
            }
            dragIsScrub = nil
            
            if scrubbing {
                // scrub ended: reset scrubbing and re-enable control tap
                scrubRate = 1
                scrubStartedPlaybackPosition = nil
                scrubSegmentOffset = 0
                controlState.scrubTarget = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    enableControlTap = true
                }
            } else {
                // dismiss swipe ended: choose whether to dismiss or reset
                if abs(offset) > 100 {
                    swipeDismiss(finalOffset: offset > 0 ? screenHeight : -screenHeight)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        enableControlTap = true
                    }
                    animateOffsetUpdate(0)
                }
            }
        }
    }
    
    func fadeDismiss() {
        isDismissing = true
        animateOpacityUpdate(0) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func swipeDismiss(finalOffset: CGFloat = UIScreen.main.bounds.height) {
        isDismissing = true
        animateOffsetUpdate(finalOffset) {
            withoutAnimation {
                dismiss()
            }
        }
    }
    
    private func hideControls(withSlide: Bool = false) {
        withAnimation(.easeOut(duration: duration)) {
            if withSlide {
                controlOffset = maxControlOffset
            }
            controlOpacity = 0
        }
    }
    
    /// Returns controls to a visible state
    private func showControls(withSlide: Bool = false) {
        guard !controlsShown else { return }
        
        controlOffset = withSlide ? maxControlOffset : 0
        
        withAnimation(.easeIn(duration: duration)) {
            controlOpacity = 1
            if withSlide {
                controlOffset = 0
            }
        }
    }
    
    private func animateOpacityUpdate(_ newOpacity: CGFloat, callback: (() -> Void)? = nil) {
        withAnimation(.easeOut(duration: duration)) {
            opacity = newOpacity
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
    
    /// Sets the offsets to the given value with animation. If a callback is given, calls it when the animation completes.
    /// - Parameters:
    ///   - newOffset: value to update offsets to
    ///   - callback: function to call when animation completes
    private func animateOffsetUpdate(_ newOffset: CGFloat, callback: (() -> Void)? = nil) {
        withAnimation(.easeOut(duration: duration)) {
            handleOffsetUpdate(newOffset)
        }
        if let callback {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                callback()
            }
        }
    }
    
    /// Updates offset, controlOffset, and opacity to match the given raw offset˜
    /// - Parameter newOffset: raw offset to update for
    private func handleOffsetUpdate(_ newOffset: CGFloat) {
        let absOffset = abs(newOffset)
        offset = newOffset
        if controlsShown {
            controlOffset = absOffset / 3
            controlOpacity = 1.0 - (controlOffset / maxControlOffset)
        }
        opacity = 1.0 - (absOffset / screenHeight)
    }
    
    /// Responds to scrub updates
    /// - Parameter value: latest scrub gesture value
    private func handleScrubUpdate(_ value: DragGesture.Value) {
        showControls()
        
        let onPlaybackBar: Bool = playbackBarHitbox?.contains(value.startLocation) ?? false
        
        // Track playback position when current scrub segment started to offset from.
        // If the scrub started on playback bar, we want to snap to the start location, so we set scrubStartedPlaybackPosition
        // to the value corresponding to the scrub start position
        if scrubStartedPlaybackPosition == nil {
            scrubStartedPlaybackPosition = onPlaybackBar ?
            value.startLocation.x / UIScreen.main.bounds.width :
            controlState.playbackPosition
        }
        
        // disable variable scrub rate if scrubbing playback bar
        if !onPlaybackBar {
            // scrub rate is controlled by the height of the scrub gesture.
            // Every 50px increases/decreases scrub rate by 2x to a max of 8x; update in increments of 10px
            let heightStep: CGFloat = value.translation.height.stepped(by: 10) / 50
            let newScrubRate: CGFloat = (1 / pow(2, heightStep)).bounded(lower: 0.125, upper: 8)
            if newScrubRate != scrubRate {
                // when the scrub rate changes, compute future scrub targets as if the translation started at the current point and scrubTarget
                scrubStartedPlaybackPosition = controlState.scrubTarget ?? controlState.playbackPosition
                scrubSegmentOffset = value.translation.width
                scrubRate = newScrubRate
            }
        }
        
        guard let scrubStartedPlaybackPosition else {
            assertionFailure("drag is scrub but scrubStartedPlaybackPosition is nil")
            return
        }
        
        // compute x translation since scrub segment began and adjust by scrub rate
        let scrubSegmentTranslation = (value.translation.width - scrubSegmentOffset) * scrubRate
        // convert translation to a percentage of scrub area
        let scrubTargetDelta = scrubSegmentTranslation / UIScreen.main.bounds.width
        let newScrubTarget = (scrubStartedPlaybackPosition + scrubTargetDelta).bounded(lower: 0, upper: 1)
        controlState.scrubTarget = newScrubTarget
    }
    
    func showQuickLook(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url) {
            quickLookUrl = fileUrl
        }
    }
}

// https://stackoverflow.com/a/75037657
// .presentationBackground doesn't behave properly on iOS 17, but this does
// TODO: iOS 17 deprecation: remove this and replace usage with .presentationBackground
private struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        InnerView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            
            superview?.superview?.backgroundColor = .clear
        }
    }
}

// swiftlint:enable file_length
