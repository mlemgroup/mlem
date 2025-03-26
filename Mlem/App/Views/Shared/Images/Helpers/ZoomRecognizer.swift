//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

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
//        guard !context.coordinator.resetting else {
//            return
//        }
//        
//        guard let bounds = context.coordinator.bounds else {
//            return
//        }
//        
//        let maxXOffset: CGFloat = max(80, ((scale - 1) / 2) * bounds.width)
//        let maxYOffset: CGFloat = max(80, ((scale - 1) / 2) * bounds.height)
//        
//        let newOffset: CGSize = .init(
//            width: targetOffset.width.softBounded(
//                softMin: -maxXOffset,
//                hardMin: -maxXOffset - 80,
//                softMax: maxXOffset,
//                hardMax: maxXOffset + 80
//            ),
//            height: targetOffset.height.softBounded(
//                softMin: -maxYOffset,
//                hardMin: -maxYOffset - 80,
//                softMax: maxYOffset,
//                hardMax: maxYOffset + 80
//            )
//        )
//        
//        Task { @MainActor in
//            offset = newOffset
//        }
    }

    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        
        let pinchGesture = PanningPinchRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(gesture:)),
            zoomScale: $scale,
            resetMomentum: context.coordinator.resetMomentum
        )
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
        return ret
    }
    
    func makeCoordinator() -> Coordinator {
        .init(scale: $scale, offset: $offset) // offset: $targetOffset)
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
        private var initialVelocity: CGPoint?
        private var velocity: CGPoint?
        
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
                link?.invalidate()
                link = nil
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
                if abs(gestureVelocity.x) + abs(gestureVelocity.y) > 40 {
                    let boost: CGFloat = 1.01
                    velocity = .init(x: gestureVelocity.x * scale * boost, y: gestureVelocity.y * scale * boost)
                    initialVelocity = velocity
                    initialScale = scale
                    initialOffset = offset

                    // TODO: NOW PERFORMANCE use CAMetalDisplayLink?
                    let link = CADisplayLink(target: self, selector: #selector(fireTimer))
                    link.preferredFramesPerSecond = 120
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
        
        /// Halts momentum physics
        @objc
        func resetMomentum() {
            link?.invalidate()
            link = nil
        }
        
        @objc
        func fireTimer(displayLink: CADisplayLink) {
            guard let velocity, let initialVelocity else {
                return
            }
            
            guard abs(velocity.x) + abs(velocity.y) > 0.0 else {
                displayLink.invalidate()
                self.link = nil
                resetToBounds(activeOffset: (offset - initialOffset)) // TODO: that's a hack
                return
            }
            
            let deltaT = displayLink.targetTimestamp - displayLink.timestamp
            
            // Adjust velocity to increment according to frame rate
            let adjustedVelocity: CGPoint = .init(
                x: velocity.x * deltaT,
                y: velocity.y * deltaT
            )
            offset = .init(
                width: offset.width + adjustedVelocity.x,
                height: offset.height + adjustedVelocity.y
            )
            
            let borderDrag = computeBorderDrag(at: offset)
            
            // apply friction
            let xDeltaV = initialVelocity.x * deltaT * borderDrag.width
            let xVelocity = abs(xDeltaV) > abs(velocity.x) ? 0 : velocity.x - xDeltaV
            
            let yDeltaV = initialVelocity.y * deltaT * borderDrag.height
            let yVelocity = abs(yDeltaV) > abs(velocity.y) ? 0 : velocity.y - yDeltaV
            
            self.velocity = .init(x: xVelocity, y: yVelocity)
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UIPinchGestureRecognizer {
                true
            } else if gestureRecognizer is UIPanGestureRecognizer {
                gestureRecognizer.numberOfTouches == 1 && scale > 1.0
            } else {
                false
            }
        }
        
        func updateScale(with scale: CGFloat, panOffset: CGSize) {
            let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
            let adjustedScale: CGFloat = targetZoomScale / initialScale
            
            self.scale = targetZoomScale
            let offsetDeltas = computeOffsetDeltas(scale: adjustedScale)
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
            
            let offsetDeltas = computeOffsetDeltas(scale: boundedScale / initialScale) + activeOffset
            let maxXOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.width
            let maxYOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.height
            
            // gesture.panOffset = .zero
            let newOffset: CGSize = .init(
                width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxXOffset, upper: maxXOffset),
                height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxYOffset, upper: maxYOffset)
            )
            
            withAnimation {
                offset = newOffset
                scale = boundedScale
            }
            
            initialOffset = newOffset
        }
        
        /// Computes the offset deltas from initialOffset required to anchor the view on the anchor point at the given scale
        private func computeOffsetDeltas(scale: CGFloat) -> CGSize {
            guard let bounds else {
                assertionFailure("No bounds")
                return .zero
            }
            
            let scaledBounds: CGSize = .init(width: bounds.width, height: bounds.height).scaled(by: initialScale)
            
            // (scale - 1) * (0.5 - anchor) computes the offset required to center the view on the anchor while zooming,
            // expressed in a percentage of the zoomed view's bounds; * scaledBounds.width transforms that into an
            // offset in real px
            let xOffset: CGFloat = (scale - 1) * (0.5 - anchor.x) * scaledBounds.width
            let yOffset: CGFloat = (scale - 1) * (0.5 - anchor.y) * scaledBounds.height
            
            return .init(width: xOffset, height: yOffset)
        }
        
        /// Computes the additional friction to apply to gestures/momentum when a view is out of bound
        private func computeBorderDrag(at offset: CGSize) -> CGSize {
            guard let bounds else {
                assertionFailure("No bounds")
                return .zero
            }
            
            let scaledBounds: CGSize = .init(width: bounds.width, height: bounds.height).scaled(by: (scale - 1) / 2)
            
            let xDrag: CGFloat
            if abs(offset.width) > scaledBounds.width {
                print("DEBUG applying x drag")
                xDrag = 2
            } else {
                xDrag = 1
            }
            
            let yDrag: CGFloat
            if abs(offset.height) > scaledBounds.height {
                yDrag = 2
            } else {
                yDrag = 1
            }
            
            print("DEBUG \(offset), \(scaledBounds)")
            return .init(width: xDrag, height: yDrag) // .zero
        }
    }
}

class PanningPinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    var resetMomentum: () -> Void
    var panOffset: CGSize = .zero
    
    init(target: Any?, action: Selector?, zoomScale: Binding<CGFloat>, resetMomentum: @escaping () -> Void) {
        _zoomScale = zoomScale
        self.resetMomentum = resetMomentum
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        resetMomentum()
        super.touchesBegan(touches, with: event)
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
