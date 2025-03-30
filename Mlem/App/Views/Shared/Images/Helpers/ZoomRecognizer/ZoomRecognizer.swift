//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

// TODO LIST
// - Fix single tap reset momentum when oob not resetting
//   - Move tap recognition into UITapGestureRecognizer
// - Single source of truth for bounds
// - Zoom slider anchoring
// - Investigate CGAffineTransform instead of scaleEffect + offset

struct ZoomRecognizer: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    @State var targetScale: CGFloat
    @State var targetOffset: CGSize
    
    init(scale: Binding<CGFloat>, offset: Binding<CGSize>) {
        _scale = scale
        _offset = offset
        _targetScale = .init(wrappedValue: scale.wrappedValue)
        _targetOffset = .init(wrappedValue: offset.wrappedValue)
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // noop
    }

    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        
        let pinchGesture = PanningPinchRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(gesture:)),
            zoomScale: $scale
        )
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
        let doubleTap: UITapGestureRecognizer = MomentumResetTapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(gesture:)),
            resetMomentum: context.coordinator.resetMomentum
        )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = context.coordinator
        ret.addGestureRecognizer(doubleTap)
        
        return ret
    }
    
    func makeCoordinator() -> Coordinator {
        .init(scale: $scale, offset: $offset)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
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
                if bounds == nil {
                    bounds = .init(width: view.bounds.width, height: view.bounds.height)
                }
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
                resetMomentum()
            case .began:
                resetMomentum()
                initialOffset = offset
                updateOffsetForPanGesture(gesture)
            case .changed:
                updateOffsetForPanGesture(gesture)
            case .ended, .cancelled:
                guard let view = gesture.view else {
                    assertionFailure("No view")
                    return
                }
                
                let gestureVelocity = gesture.velocity(in: view)
                let maxXOffset: CGFloat = ((scale - 1) / 2) * view.bounds.width
                let maxYOffset: CGFloat = ((scale - 1) / 2) * view.bounds.height
                let xOob = abs(offset.width) >= maxXOffset
                let yOob = abs(offset.height) >= maxYOffset
                if !(xOob && yOob),
                   abs(gestureVelocity.x) + abs(gestureVelocity.y) > 40 {
                    initialScale = scale
                    initialOffset = offset
                    
                    let xVelo: CGFloat
                    if xOob {
                        let xBound: CGFloat = offset.width < 0 ? -maxXOffset : maxXOffset
                        initialOffset.width = xBound
                        xVelo = offset.width - xBound
                    } else {
                        xVelo = gestureVelocity.x * scale
                    }
                    
                    let yVelo: CGFloat
                    if yOob {
                        let yBound: CGFloat = offset.height < 0 ? -maxYOffset : maxYOffset
                        initialOffset.height = yBound
                        yVelo = offset.height - yBound
                    } else {
                        yVelo = gestureVelocity.y * scale
                    }
                    
                    momentum = .init(
                        initialVelocity: .init(x: xVelo, y: yVelo),
                        bounds: .init(width: maxXOffset, height: maxYOffset),
                        xOob: xOob,
                        yOob: yOob
                    )

                    let link = CADisplayLink(target: self, selector: #selector(fireTimer))
                    link.preferredFrameRateRange = .init(minimum: 60, maximum: 90, __preferred: 90)
                    link.add(to: .current, forMode: .default)
                    self.link = link
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
                assertionFailure("Tap gesture had no view")
                return
            }
            
            let targetZoomScale: CGFloat
            let newOffset: CGSize
            if scale == 1 {
                let location = gesture.location(in: view)
                targetZoomScale = 3
                anchor = .init(x: location.x / view.bounds.width, y: location.y / view.bounds.height)
                let adjustedScale: CGFloat = targetZoomScale / scale
                let offsetDeltas = computeOffsetDeltas(
                    scale: adjustedScale,
                    bounds: .init(width: view.bounds.width, height: view.bounds.height)
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
  
            // set up initial times
            if momentum.xt0 == nil {
                momentum.xt0 = displayLink.timestamp
            }
            if momentum.yt0 == nil {
                momentum.yt0 = displayLink.timestamp
            }
            
            // check out-of-bounds
            if !momentum.xOob, abs(offset.width) >= momentum.bounds.width {
                initialOffset.width = momentum.bounds.width * (offset.width < 0 ? -1 : 1)
                momentum.xLeftBounds(at: displayLink.timestamp)
            }
            if !momentum.yOob, abs(offset.height) >= momentum.bounds.height {
                initialOffset.height = momentum.bounds.height * (offset.height < 0 ? -1 : 1)
                momentum.yLeftBounds(at: displayLink.timestamp)
            }
            
            // compute offset
            let (increment, active) = momentum.position(at: displayLink.targetTimestamp)
            
            offset = initialOffset + increment
            if !active { resetMomentum() }
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
            // let panOffset = gesture.panOffset
            resetToBounds(activeOffset: gesture.panOffset)
            gesture.panOffset = .zero
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
            
            // gesture.panOffset = .zero
            let newOffset: CGSize = .init(
                width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxXOffset, upper: maxXOffset),
                height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxYOffset, upper: maxYOffset)
            )
            
            withAnimation(.easeOut(duration: 0.25)) {
                offset = newOffset
                scale = boundedScale
            }
            
            initialOffset = newOffset
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
}

class MomentumResetTapGestureRecognizer: UITapGestureRecognizer {
    var resetMomentum: () -> Void
    
    init(target: Any?, action: Selector?, resetMomentum: @escaping () -> Void) {
        self.resetMomentum = resetMomentum
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        resetMomentum()
        super.touchesBegan(touches, with: event)
    }
}

class PanningPinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    var panOffset: CGSize = .zero
    
    init(target: Any?, action: Selector?, zoomScale: Binding<CGFloat>) {
        _zoomScale = zoomScale
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard state == .began || state == .changed else { return }
        let translation = translation(of: touches)
        panOffset += translation.scaled(by: zoomScale)
    }
    
    private func translation(of touches: Set<UITouch>) -> CGSize {
        var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.location(in: view)
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        
        var previousLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.previousLocation(in: view)
        }
        previousLocation.x /= CGFloat(touches.count)
        previousLocation.y /= CGFloat(touches.count)
        
        return .init(
            width: averageLocation.x - previousLocation.x,
            height: averageLocation.y - previousLocation.y
        )
    }
}

private extension CGFloat {
    /// Returns the value of this CGFloat bounded within the given range. If this float is above softMax, the returned
    /// value will asymptotically approach hardMax, and likewise for softMin and hardMin
    func softBounded(softMin: CGFloat, hardMin: CGFloat, softMax: CGFloat, hardMax: CGFloat) -> CGFloat {
        guard softMin > hardMin, softMax < hardMax, softMin < softMax else {
            if softMin <= hardMin {
                assertionFailure("Soft min \(softMin) <= hard min \(hardMin)")
            }
            if softMax >= hardMax {
                assertionFailure("Soft max \(softMax) >= hard max \(hardMax)")
            }
            if softMin >= softMax {
                assertionFailure("Soft min \(softMin) >= soft max \(softMax)")
            }
            return self
        }
        
        if self > softMax {
            let headroom = hardMax - softMax
            let excess = self - softMax
            let scaledExcess = headroom - asymptote(x: excess, n: headroom)
            return softMax + scaledExcess
        }
        
        if self < softMin {
            let headroom = softMin - hardMin
            let excess = softMin - self
            let scaledExcess = asymptote(x: excess, n: headroom) - headroom
            return softMin + scaledExcess
        }
        
        return self
    }
    
    /// Base asymptotic function used for softBounded, where x is the value to scale and n is the asymptotic bound
    private func asymptote(x: CGFloat, n: CGFloat) -> CGFloat { // swiftlint:disable:this identifier_name
        n / (((1 / n) * x) + 1)
    }
}

private extension UnitPoint {
    func scaled(by factor: CGFloat) -> UnitPoint {
        return .init(x: x * factor, y: y * factor)
    }
}

private extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    func scaled(by factor: CGFloat) -> CGSize {
        return .init(width: width * factor, height: height * factor)
    }
}

private extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
