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
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
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
            case .ended, .cancelled:
                endGesture(gesture: gesture)
            case .failed:
                print("DEBUG pinch gesture failed")
            default:
                assertionFailure("Unknown state")
            }
        }
        
        // TODO: NOW clean this up
        // TODO: NOW compute initialOffset at the beginning and not the end
        @objc
        func handlePan(gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .possible:
                break
            case .began, .changed:
                guard let view = gesture.view else {
                    assertionFailure("No view")
                    return
                }
                let translation = gesture.translation(in: view)
                offset = initialOffset + .init(width: translation.x, height: translation.y).scaled(by: scale)
            case .ended, .cancelled:
                guard let bounds else {
                    assertionFailure("No bounds")
                    return
                }
                
                guard let view = gesture.view else {
                    assertionFailure("No view")
                    return
                }
                
                let boundedScale: CGFloat = scale.bounded(lower: 1.0, upper: 4.0)
                let maxXOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.width
                let maxYOffset: CGFloat = ((boundedScale - 1) / 2) * bounds.height
                
                let translation = gesture.translation(in: view)
                let panOffset: CGSize = .init(width: translation.x, height: translation.y).scaled(by: scale)
                let newOffset: CGSize = .init(
                    width: (initialOffset.width + panOffset.width).bounded(lower: -maxXOffset, upper: maxXOffset),
                    height: (initialOffset.height + panOffset.height).bounded(lower: -maxYOffset, upper: maxYOffset)
                )
                
                withAnimation {
                    offset = newOffset
                    scale = boundedScale
                }
                
                initialOffset = newOffset
            case .failed:
                print("DEBUG pan gesture failed")
            default:
                assertionFailure("Unknown state")
            }
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
    
        func beginGesture(at location: CGPoint) {
            guard let bounds else {
                assertionFailure("No bounds")
                return
            }
            
            initialScale = scale
            initialOffset = offset
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
