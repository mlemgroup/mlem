//
//  ZoomRecognizerCoordinator.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-30.
//

import UIKit
import SwiftUICore

class ZoomRecognizerCoordinator: NSObject, UIGestureRecognizerDelegate {
    @Setting(\.zoomSliderLocation) var zoomSliderLocation
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    /// Scale when the current pinch began
    private var initialScale: CGFloat = 1.0
    
    /// Offset when the current gesture began
    private var initialOffset: CGSize = .zero
    
    /// Point in the image where the gesture is anchored
    private var anchor: UnitPoint = .center
    
    private var link: CADisplayLink?
    private var momentum: MomentumStatus?
    
    /// Bounds of the view
    var bounds: CGSize?
    
    var resetting: Bool = false
    
    init(scale: Binding<CGFloat>, offset: Binding<CGSize>) {
        _scale = scale
        _offset = offset
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UITapGestureRecognizer {
            return true
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            true
        } else if gestureRecognizer is UIPanGestureRecognizer {
            gestureRecognizer.numberOfTouches == 1 && scale > 1.0
        } else {
            false
        }
    }
    
    // MARK: - Handlers
    
    @objc
    func handlePinch(gesture: PanningPinchRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            guard let view = gesture.view else {
                assertionFailure("No view")
                return
            }
            initializeBounds(view: view)
            resetMomentum()
            beginPinch(at: gesture.location(in: view))
        case .changed:
            updateScale(with: gesture.scale, panOffset: gesture.panOffset)
        case .ended, .cancelled:
            endPinch(gesture: gesture)
        case .failed:
            print("DEBUG pinch gesture failed")
        default:
            assertionFailure("Unknown state")
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            guard let view = gesture.view else {
                assertionFailure("No view")
                return
            }
            initializeBounds(view: view)
            
            print("DEBUG \(gesture.location(in: nil))")
            
            resetMomentum()
            initialOffset = offset
            updateOffsetForPanGesture(gesture)
        case .changed:
            updateOffsetForPanGesture(gesture)
        case .ended, .cancelled:
            guard let view = gesture.view, let bounds else {
                assertionFailure("Missing view or bounds")
                return
            }
            
            let gestureVelocity = gesture.velocity(in: view)
            let maxXOffset: CGFloat = ((scale - 1) / 2) * bounds.width
            let maxYOffset: CGFloat = ((scale - 1) / 2) * bounds.height
            let xOob = abs(offset.width) >= maxXOffset
            let yOob = abs(offset.height) >= maxYOffset
            if !(xOob && yOob),
               abs(gestureVelocity.x) + abs(gestureVelocity.y) > 40 {
                startMomentum(velocity: gestureVelocity, xOob: xOob, yOob: yOob, maxXOffset: maxXOffset, maxYOffset: maxYOffset)
            } else {
                let translation = gesture.translation(in: view)
                resetToBounds(activeOffset: .init(width: translation.x, height: translation.y).scaled(by: scale))
            }
        case .failed:
            print("DEBUG pan gesture failed")
        default:
            assertionFailure("Unknown state")
        }
    }
    
    @objc
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else {
            assertionFailure("No view")
            return
        }
        initializeBounds(view: view)
        
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        let targetZoomScale: CGFloat
        let newOffset: CGSize
        if scale == 1 {
            let location = gesture.location(in: view)
            targetZoomScale = 3
            anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
            let adjustedScale: CGFloat = targetZoomScale / scale
            let offsetDeltas = computeOffsetDeltas(
                scale: adjustedScale,
                bounds: .init(width: bounds.width, height: bounds.height)
            )
            newOffset = offset + offsetDeltas
        } else {
            targetZoomScale = 1
            anchor = .center
            newOffset = .zero
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = newOffset
            scale = targetZoomScale
        }
    }
    
    @objc
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        initializeBounds(view: gesture.view)
        
        if let bounds {
            let maxXOffset: CGFloat = ((scale - 1) / 2) * bounds.width
            let maxYOffset: CGFloat = ((scale - 1) / 2) * bounds.height
            if abs(offset.width) > maxXOffset || abs(offset.height) > maxYOffset {
                resetToBounds(activeOffset: offset - initialOffset)
            }
        }
    }
    
    // MARK: - Helpers
    
    func startMomentum(velocity: CGPoint, xOob: Bool, yOob: Bool, maxXOffset: CGFloat, maxYOffset: CGFloat) {
        initialScale = scale
        initialOffset = offset
        
        let xVelo: CGFloat
        if xOob {
            let xBound: CGFloat = offset.width < 0 ? -maxXOffset : maxXOffset
            initialOffset.width = xBound
            xVelo = offset.width - xBound
        } else {
            xVelo = velocity.x * scale
        }
        
        let yVelo: CGFloat
        if yOob {
            let yBound: CGFloat = offset.height < 0 ? -maxYOffset : maxYOffset
            initialOffset.height = yBound
            yVelo = offset.height - yBound
        } else {
            yVelo = velocity.y * scale
        }
        
        momentum = .init(
            initialVelocity: .init(x: xVelo, y: yVelo),
            xOob: xOob,
            yOob: yOob
        )
        
        let link = CADisplayLink(target: self, selector: #selector(fireTimer))
        link.preferredFrameRateRange = .init(minimum: 60, maximum: 90, __preferred: 90)
        link.add(to: .current, forMode: .default)
        self.link = link
    }
    
    /// Halts momentum physics
    @objc
    func resetMomentum() {
        link?.invalidate()
        link = nil
        momentum = nil
    }
    
    @objc
    func fireTimer(displayLink: CADisplayLink) {
        guard let momentum else {
            assertionFailure("Timer fired with no momentum")
            return
        }
        
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        // set up initial times
        if momentum.xt0 == nil {
            momentum.xt0 = displayLink.timestamp
        }
        if momentum.yt0 == nil {
            momentum.yt0 = displayLink.timestamp
        }
        
        let maxXOffset: CGFloat = ((scale - 1) / 2) * bounds.width
        let maxYOffset: CGFloat = ((scale - 1) / 2) * bounds.height
        
        // check out-of-bounds
        if !momentum.xOob, abs(offset.width) >= maxXOffset {
            initialOffset.width = maxXOffset * (offset.width < 0 ? -1 : 1)
            momentum.xLeftBounds(at: displayLink.timestamp)
        }
        if !momentum.yOob, abs(offset.height) >= maxYOffset {
            initialOffset.height = maxYOffset * (offset.height < 0 ? -1 : 1)
            momentum.yLeftBounds(at: displayLink.timestamp)
        }
        
        // compute offset
        let (increment, active) = momentum.position(at: displayLink.targetTimestamp)
        
        offset = initialOffset + increment
        if !active { resetMomentum() }
    }
    
    func updateScale(with scale: CGFloat, panOffset: CGSize) {
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
        let adjustedScale: CGFloat = targetZoomScale / initialScale
        
        self.scale = targetZoomScale
        let offsetDeltas = computeOffsetDeltas(scale: adjustedScale, bounds: bounds)
        offset = initialOffset + panOffset + offsetDeltas
    }
    
    /// Updates offset according to the translation of the given pan gesture recognizer
    func updateOffsetForPanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            assertionFailure("No view")
            return
        }
        
        let translation = gesture.translation(in: view)
        offset = initialOffset + .init(width: translation.x, height: translation.y).scaled(by: scale)
    }
    
    func beginPinch(at location: CGPoint) {
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        initialScale = scale
        initialOffset = offset
        anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
    }
    
    func endPinch(gesture: PanningPinchRecognizer) {
        resetToBounds(activeOffset: gesture.panOffset)
        gesture.panOffset = .zero
    }
    
    func initializeBounds(view: UIView?) {
        guard let view else {
            assertionFailure("No view")
            return
        }
        
        if bounds == nil, view.bounds != .zero {
            bounds = .init(width: view.bounds.width, height: view.bounds.height)
        }
    }
    
    private func isOutOfBounds(offset: CGSize) -> Bool {
        guard let bounds else {
            assertionFailure("No bounds")
            return false
        }
        return abs(offset.width) > bounds.width || abs(offset.height) > bounds.height
    }
    
    /// Resets offset and scale to be within bounds
    private func resetToBounds(activeOffset: CGSize) {
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        let boundedScale: CGFloat = scale.bounded(lower: 1.0, upper: 4.0)
        
        let offsetDeltas = computeOffsetDeltas(scale: boundedScale / initialScale, bounds: bounds) + activeOffset
        let maxXOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.width
        let maxYOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.height
        
        let newOffset: CGSize = .init(
            width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxXOffset, upper: maxXOffset),
            height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxYOffset, upper: maxYOffset)
        )
        
        withAnimation(.easeOut(duration: 0.25)) {
            offset = newOffset
            scale = boundedScale
        }
        
        initialOffset = newOffset
        anchor = .init(x: newOffset.width / bounds.width, y: newOffset.height / bounds.height)
    }
    
    /// Computes the offset deltas from initialOffset required to anchor the view on the anchor point at the given scale
    private func computeOffsetDeltas(scale: CGFloat, bounds: CGSize) -> CGSize {
        let scaledBounds: CGSize = .init(width: bounds.width, height: bounds.height).scaled(by: initialScale)
        
        // (scale - 1) * (0.5 - anchor) computes the offset required to center the view on the anchor while zooming,
        // expressed in a percentage of the zoomed view's bounds; * scaledBounds.width transforms that into an
        // offset in real px
        let xOffset: CGFloat = (scale - 1) * (0.5 - anchor.x) * scaledBounds.width
        let yOffset: CGFloat = (scale - 1) * (0.5 - anchor.y) * scaledBounds.height
        
        return .init(width: xOffset, height: yOffset)
    }
}
