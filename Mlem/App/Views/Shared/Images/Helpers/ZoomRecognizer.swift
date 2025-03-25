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

    func updateUIView(_ uiView: UIView, context: Context) {
        // noop
    }

    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        
        let pinchGesture = PanningPinchRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(gesture:)),
            zoomScale: $scale)
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)
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
        
        /// Offset when the current pinch began
        private var initialOffset: CGSize = .zero
        
        /// Offset needed to anchor the pinch gesture to anchor
        private var pinchOffset: CGSize = .zero
        
        /// Offset induced by the pan gesture
        private var panOffset: CGSize = .zero
        
        /// Point in the image where the gesture is anchored
        private var anchor: UnitPoint = .center
        
        /// Bounds of the view
        private var bounds: CGSize?
        
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
                beginGesture(at: gesture.location(in: view))
            case .changed:
                updateScale(with: gesture.scale, panOffset: gesture.panOffset)
            case .ended, .cancelled, .failed:
                endGesture(gesture: gesture)
            default:
                assertionFailure("Unknown state")
            }
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if gestureRecognizer is UIPinchGestureRecognizer {
                true
            } else if gestureRecognizer is UIPanGestureRecognizer {
                gestureRecognizer.numberOfTouches == 2
            } else {
                false
            }
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            gestureRecognizer is UIPinchGestureRecognizer ||
            otherGestureRecognizer is UIPinchGestureRecognizer
        }
    
        func beginGesture(at location: CGPoint) {
            guard let bounds else {
                assertionFailure("No bounds")
                return
            }
            
            initialScale = scale
            initialOffset = offset
            pinchOffset = .zero
            anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
        }
        
        func updateScale(with scale: CGFloat, panOffset: CGSize) {
            let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
            let adjustedScale: CGFloat = targetZoomScale / initialScale
            
            self.scale = targetZoomScale
            let offsetDeltas = computeOffsetDeltas(scale: adjustedScale)
            offset = initialOffset + panOffset + offsetDeltas
        }
        
        func endGesture(gesture: PanningPinchRecognizer) {
            guard let bounds else {
                assertionFailure("No bounds")
                return
            }
            
            let boundedScale: CGFloat = scale.bounded(lower: 1.0, upper: 4.0)
            
            let offsetDeltas = computeOffsetDeltas(scale: boundedScale / initialScale) + gesture.panOffset
            let maxXOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.width
            let maxYOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.height
            
            gesture.panOffset = .zero
            
            withAnimation {
                offset = .init(
                    width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxXOffset, upper: maxXOffset),
                    height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxYOffset, upper: maxYOffset)
                )
                scale = boundedScale
            }
        }
        
        ///
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
        let translation = translation(of: touches)
        panOffset += translation.scaled(by: zoomScale)
        super.touchesMoved(touches, with: event)
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

class PinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGSize

    /// Scale when the current pinch began
    private var initialScale: CGFloat = 1.0
    
    /// Offset when the current pinch began
    private var initialOffset: CGSize = .zero
    
    private var panOffset: CGSize = .zero
    
    private var previousAnchor: UnitPoint = .zero
    
    private var anchor: UnitPoint = .center
    
    private var debounce: Bool = false

    init(
        target: Any?,
        action: Selector?,
        zoomScale: Binding<CGFloat>,
        offset: Binding<CGSize>
    ) {
        _zoomScale = zoomScale
        _offset = offset
        super.init(target: target, action: action)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        initialScale = zoomScale
        initialOffset = offset
        panOffset = .zero
        
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        
        // compute anchor point--this should remain in the middle of the pinch/pan gesture
        var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.location(in: view)
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        anchor = .init(x: averageLocation.x / bounds.width, y: averageLocation.y / bounds.height)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard !debounce else { return }
        let targetZoomScale: CGFloat = (initialScale * scale).softBounded(softMin: 1, hardMin: 0.6, softMax: 4, hardMax: 6)
        let adjustedScale: CGFloat = targetZoomScale / initialScale
        zoomScale = targetZoomScale
        
        let offsetDeltas = computeOffsetDeltas(scale: adjustedScale)
        
        let translation = translation(of: touches)
        panOffset += translation.scaled(by: zoomScale)
        
        offset = initialOffset + offsetDeltas + panOffset
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        
        debounce = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.debounce = false
        }
        
        let boundedZoomScale: CGFloat = zoomScale.bounded(lower: 1.0, upper: 4.0)
        
        let offsetDeltas = computeOffsetDeltas(scale: boundedZoomScale / initialScale) + panOffset
        let maxXOffset: CGFloat = ((boundedZoomScale - 1) / 2) * bounds.width
        let maxYOffset: CGFloat = ((boundedZoomScale - 1) / 2) * bounds.height
        
        withAnimation {
            offset = .init(
                width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxXOffset, upper: maxXOffset),
                height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxYOffset, upper: maxYOffset)
            )
            zoomScale = boundedZoomScale
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    private func computeOffsetDeltas(scale: CGFloat) -> CGSize {
        guard let bounds = view?.bounds else {
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
            assertionFailure("Invalid bounds")
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
