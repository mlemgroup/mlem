//
//  ZoomRecognizerCoordinator+Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

import UIKit
import SwiftUI

extension ZoomRecognizerCoordinator {
    
    // MARK: - Pan handlers
    
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
    
    /// Updates offset according to the translation of the given pan gesture recognizer
    func updateOffsetForPanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            assertionFailure("No view")
            return
        }
        
        let translation = gesture.translation(in: view)
        offset = initialOffset + .init(width: translation.x, height: translation.y).scaled(by: scale)
    }
    
    // MARK: - Pinch handlers
    
    func beginPinch(at location: CGPoint) {
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        initialScale = scale
        initialOffset = offset
        anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
    }
    
    func updatePinch(with scale: CGFloat, panOffset: CGSize) {
        let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
        let adjustedScale: CGFloat = targetZoomScale / initialScale
        
        self.scale = targetZoomScale
        let offsetDeltas = computeOffsetDeltas(scaleFactor: adjustedScale)
        offset = initialOffset + panOffset + offsetDeltas
    }
    
    func endPinch(gesture: PanningPinchRecognizer) {
        resetToBounds(activeOffset: gesture.panOffset)
        gesture.panOffset = .zero
    }
    
    // MARK: - Momentum
    
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
        link.preferredFrameRateRange = .init(minimum: 80, maximum: 100, __preferred: 100)
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
    
    // MARK: - Zoom
    
    /// Computes the difference that needs to be applied to the offset to anchor the zoom effect at `anchor` for
    /// a given `scaleFactor`, where `scaleFactor` is the ratio of the target scale to the scale when `anchor` was set.
    func computeOffsetDeltas(scaleFactor: CGFloat) -> CGSize {
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
    
    // MARK: - Bounds
    
    func initializeBounds(view: UIView?) {
        guard let view else {
            assertionFailure("No view")
            return
        }
        
        if bounds == nil, view.bounds != .zero {
            bounds = .init(width: view.bounds.width, height: view.bounds.height)
        }
    }
    
     func isOutOfBounds(offset: CGSize) -> Bool {
        guard let bounds else {
            assertionFailure("No bounds")
            return false
        }
        return abs(offset.width) > bounds.width || abs(offset.height) > bounds.height
    }
    
    /// Resets offset and scale to be within bounds
    func resetToBounds(activeOffset: CGSize) {
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
}
