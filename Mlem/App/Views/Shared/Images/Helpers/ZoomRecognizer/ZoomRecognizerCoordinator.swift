//
//  ZoomRecognizerCoordinator.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-30.
//

import UIKit
import SwiftUI

private enum PanType {
    case move, zoom, custom, none
}

// swiftlint:disable:next type_body_length
class ZoomRecognizerCoordinator: NSObject, UIGestureRecognizerDelegate {
    @Setting(\.zoomSliderLocation) var zoomSliderLocation
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    let customDragMoved: ((BridgeDragValue) -> Void)?
    let customDragEnded: (() -> Void)?
    let customTap: (() -> Void)?
    
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
    // TODO: NOW can this be private?
    
    private var panType: PanType = .none
    
    /// Computes the maximum allowed offsets for a given scale.
    /// - Note: to get the minimum offset, multiply the return value by -1.
    lazy var maxOffsets: CachedComputation<CGFloat, CGSize> = .init { input in
        guard let bounds = self.bounds else {
            assertionFailure("No bounds")
            return .zero
        }
        return bounds.scaled(by: (input - 1) / 2)
    }
    
    let leftZoomSliderHitbox: CGRect = .init(
        origin: .init(x: 0, y: 70),
        size: .init(width: 40, height: UIScreen.main.bounds.height - 140)
    )
    let rightZoomSliderHitbox: CGRect = .init(
        origin: .init(x: UIScreen.main.bounds.width - 40, y: 70),
        size: .init(width: 40, height: UIScreen.main.bounds.height - 140)
    )
    
    init(
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        customDragMoved: ((BridgeDragValue) -> Void)? = nil,
        customDragEnded: (() -> Void)? = nil,
        customTap: (() -> Void)? = nil
    ) {
        _scale = scale
        _offset = offset
        self.customDragMoved = customDragMoved
        self.customDragEnded = customDragEnded
        self.customTap = customTap
        
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let doubleTap = gestureRecognizer as? UITapGestureRecognizer {
            if doubleTap.numberOfTapsRequired == 2, otherGestureRecognizer is UIPanGestureRecognizer {
                // prevents quick pan gestures from triggering as double tap
                return false
            }
            return true
        }
        return false
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // single tap should require double tap to fail unless it killed momentum
        if let momentumResetGesture = gestureRecognizer as? MomentumResetTapGestureRecognizer,
           !momentumResetGesture.momentumKilled,
           let doubleTap = otherGestureRecognizer as? UITapGestureRecognizer,
           doubleTap.numberOfTapsRequired == 2 {
            return true
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            return true
        } else if gestureRecognizer is UIPanGestureRecognizer {
            let location = gestureRecognizer.location(in: nil)
            if gestureRecognizer.numberOfTouches == 1 {
                if zoomSliderLocation.leftEnabled && leftZoomSliderHitbox.contains(location) ||
                    zoomSliderLocation.rightEnabled && rightZoomSliderHitbox.contains(location) {
                    panType = .zoom
                    return true
                } else if scale > 1.0 {
                    panType = .move
                    return true
                } else {
                    panType = .custom
                    return true
                }
            }
            return false
        } else {
            return false
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
        switch panType {
        case .move:
            handleMovePan(gesture: gesture)
        case .zoom:
            handleZoomPan(gesture: gesture)
        case .custom:
            handleCustomPan(gesture: gesture)
        case .none:
            assertionFailure("Pan started with no valid pan type")
        }
    }
    
    func handleMovePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            initializeBounds(view: gesture.view)
            resetMomentum()
            initialOffset = offset
            updateOffsetForPanGesture(gesture)
        case .changed:
            updateOffsetForPanGesture(gesture)
        case .ended, .cancelled:
            panType = .none
            guard let view = gesture.view else {
                assertionFailure("Missing view or bounds")
                return
            }
            
            initialScale = scale
            
            let gestureVelocity = gesture.velocity(in: view)
            let maxOffsets = maxOffsets.compute(scale)
            let xOob = abs(offset.width) >= maxOffsets.width
            let yOob = abs(offset.height) >= maxOffsets.height
            if !(xOob && yOob),
               abs(gestureVelocity.x) + abs(gestureVelocity.y) > 40 {
                startMomentum(
                    velocity: gestureVelocity,
                    xOob: xOob,
                    yOob: yOob,
                    maxXOffset: maxOffsets.width,
                    maxYOffset: maxOffsets.height
                )
            } else {
                let translation = gesture.translation(in: view)
                resetToBounds(activeOffset: .init(width: translation.x, height: translation.y).scaled(by: scale))
            }
        case .failed:
            panType = .none
            print("DEBUG pan gesture failed")
        default:
            assertionFailure("Unknown state")
        }
    }
    
    func handleZoomPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            initializeBounds(view: gesture.view)
            guard let bounds else {
                assertionFailure("No bounds")
                return
            }
            resetMomentum()
            initialScale = scale
            initialOffset = offset
            let xAnchor = (((scale * bounds.width) / 2) - offset.width) / (scale * bounds.width)
            let yAnchor = (((scale * bounds.height) / 2) - offset.height) / (scale * bounds.height)
            anchor = .init(x: xAnchor, y: yAnchor)
        case .changed:
            let newScale = (initialScale + (gesture.translation(in: nil).y / -60)).bounded(lower: 1.0, upper: 4.0)
            let maxOffsets = maxOffsets.compute(newScale)
            let offsetDeltas = computeOffsetDeltas(scaleFactor: newScale / initialScale)
            let newOffset = initialOffset + offsetDeltas
            
            scale = newScale
            offset = .init(
                width: newOffset.width.bounded(lower: -maxOffsets.width, upper: maxOffsets.width),
                height: newOffset.height.bounded(lower: -maxOffsets.height, upper: maxOffsets.height)
            )
        case .ended, .cancelled:
            panType = .none
        case .failed:
            panType = .none
            print("DEBUG pan gesture failed")
        default:
            assertionFailure("Unknown state")
        }
    }

    func handleCustomPan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began, .changed:
            customDragMoved?(.init(uiPanGesture: gesture))
        case .ended, .cancelled:
            if let customDragEnded {
                customDragEnded()
            }
        case .failed:
            break
        default:
            assertionFailure("Unrecognized state")
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
        
        initialOffset = offset
        initialScale = scale
        
        let targetZoomScale: CGFloat
        let newOffset: CGSize
        if scale == 1 {
            let location = gesture.location(in: view)
            targetZoomScale = 3
            anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
            let offsetDeltas = computeOffsetDeltas(scaleFactor: targetZoomScale / initialScale)
            let maxOffsets = maxOffsets.compute(targetZoomScale)
            
            newOffset = .init(
                width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxOffsets.width, upper: maxOffsets.width),
                height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxOffsets.height, upper: maxOffsets.height)
            )
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
    func handleSingleTap(gesture: MomentumResetTapGestureRecognizer) {
        initializeBounds(view: gesture.view)

        let maxOffsets = maxOffsets.compute(scale)
        if abs(offset.width) > maxOffsets.width || abs(offset.height) > maxOffsets.height {
            resetToBounds(activeOffset: offset - initialOffset)
        }
        
        if gesture.momentumKilled {
            gesture.momentumKilled = false
        } else if let customTap {
            customTap()
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
        
        let link = CADisplayLink(target: self, selector: #selector(tickMomentum))
        link.preferredFrameRateRange = .init(minimum: 60, maximum: 90, __preferred: 90)
        link.add(to: .current, forMode: .default)
        self.link = link
    }
    
    @objc
    func tickMomentum(displayLink: CADisplayLink) {
        guard let momentum else {
            assertionFailure("Timer fired with no momentum")
            return
        }
        
        // set up initial times
        if momentum.xt0 == nil {
            momentum.xt0 = displayLink.timestamp
        }
        if momentum.yt0 == nil {
            momentum.yt0 = displayLink.timestamp
        }
        
        let maxOffsets = maxOffsets.compute(scale)
        
        // check out-of-bounds
        if !momentum.xOob, abs(offset.width) >= maxOffsets.width {
            initialOffset.width = maxOffsets.width * (offset.width < 0 ? -1 : 1)
            momentum.xLeftBounds(at: displayLink.timestamp)
        }
        if !momentum.yOob, abs(offset.height) >= maxOffsets.height {
            initialOffset.height = maxOffsets.height * (offset.height < 0 ? -1 : 1)
            momentum.yLeftBounds(at: displayLink.timestamp)
        }
        
        // compute offset
        let (increment, active) = momentum.position(at: displayLink.targetTimestamp)
        
        offset = initialOffset + increment
        if !active { resetMomentum() }
    }
    
    /// Halts momentum physics
    /// - Returns: true if momentum was killed, false if noop (no momentum when called)
    @discardableResult
    @objc
    func resetMomentum() -> Bool {
        let ret = momentum != nil
        link?.invalidate()
        link = nil
        momentum = nil
        return ret
    }
    
    func updateScale(with scale: CGFloat, panOffset: CGSize) {
        let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
        let adjustedScale: CGFloat = targetZoomScale / initialScale
        
        self.scale = targetZoomScale
        let offsetDeltas = computeOffsetDeltas(scaleFactor: adjustedScale)
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
        
        let offsetDeltas = computeOffsetDeltas(scaleFactor: boundedScale / initialScale) + activeOffset
        let maxOffsets = maxOffsets.compute(boundedScale)
        
        let newOffset: CGSize = .init(
            width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxOffsets.width, upper: maxOffsets.width),
            height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxOffsets.height, upper: maxOffsets.height)
        )
        
        withAnimation(.easeOut(duration: 0.25)) {
            offset = newOffset
            scale = boundedScale
        }
        
        initialOffset = newOffset
        anchor = .init(x: newOffset.width / bounds.width, y: newOffset.height / bounds.height)
    }
    
    /// Computes the difference that needs to be applied to the offset to anchor the zoom effect at `anchor` for
    /// a given `scaleFactor`, where `scaleFactor` is the ratio of the target scale to the scale when `anchor` was set.
    private func computeOffsetDeltas(scaleFactor: CGFloat) -> CGSize {
        guard let bounds else {
            assertionFailure("No bounds")
            return .zero
        }
        let scaledBounds: CGSize = .init(width: bounds.width, height: bounds.height).scaled(by: initialScale)
        
        // (scale - 1) * (0.5 - anchor) computes the offset required to center the view on the anchor while zooming,
        // expressed in a percentage of the zoomed view's bounds; * scaledBounds.width transforms that into an
        // offset in real px
        let xOffset: CGFloat = (scaleFactor - 1) * (0.5 - anchor.x) * scaledBounds.width
        let yOffset: CGFloat = (scaleFactor - 1) * (0.5 - anchor.y) * scaledBounds.height
        
        return .init(width: xOffset, height: yOffset)
    }
}
