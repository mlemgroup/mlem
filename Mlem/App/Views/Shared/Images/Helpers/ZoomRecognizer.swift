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
        
        let pinchGesture = PinchRecognizer(
            target: context.coordinator,
            action: nil,
            zoomScale: $scale,
            offset: $offset
        )
        ret.addGestureRecognizer(pinchGesture)

        return ret
    }
}

class PinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGSize

    /// Scale when the current pinch began
    private var initialScale: CGFloat = 1.0
    
    /// Offset when the current pinch began
    private var initialOffset: CGSize = .zero
    
    private var previousAnchor: UnitPoint = .zero
    
    private var anchor: UnitPoint = .center

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
        
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.location(in: view)
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        
        print("DEBUG average: \(averageLocation)")
        anchor = .init(x: averageLocation.x / bounds.width, y: averageLocation.y / bounds.height)
        print("DEBUG anchor: \(anchor)")
//        // previousScale = zoomScale
//        previousAnchor = anchor
//        initialOffset = offset
//        
//        if let bounds = view?.bounds {
//            print("DEBUG \(bounds)")
//            print("DEBUG \(view?.frame)")
//            
//            // compute location in
//            var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
//                result += touch.location(in: view)
//            }
//            averageLocation.x /= CGFloat(touches.count)
//            averageLocation.y /= CGFloat(touches.count)
//            let newAnchor: UnitPoint = .init(
//                x: averageLocation.x / bounds.width,
//                y: averageLocation.y / bounds.height
//            )
//            
//            // update offset to handle anchor shift
//            let anchorDeltaX: CGFloat = ((newAnchor.x - previousAnchor.x) * bounds.width) / 2
//            let anchorDeltaY: CGFloat = ((newAnchor.y - previousAnchor.y) * bounds.height) / 2
//            let newOffset: CGSize = .init(
//                width: offset.width + anchorDeltaX,
//                height: offset.height + anchorDeltaY
//            )
//            
//            offset = newOffset
//            anchor = newAnchor
//            
//            print("DEBUG \(anchor)")
//        } else {
//            assertionFailure("No view")
//            anchor = .init(x: 0.5, y: 0.5)
//        }
        
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        // previousScale = zoomScale
        zoomScale = initialScale * scale
        // let scaleDelta: CGFloat = zoomScale / initialScale
        
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        print("DEBUG xOffset: \((scale - 1) * (0.5 - anchor.x))")
        // compute bounds size in real px
        let scaledBounds: CGSize = .init(width: bounds.width, height: bounds.height).scaled(by: initialScale)
        
        // (scale - 1) * (0.5 - anchor) computes the offset required to center the view on the anchor while zooming,
        // expressed in a percentage of the zoomed view's bounds; * scaledBounds.width transforms that into an
        // offset in real px
        let xOffset: CGFloat = (scale - 1) * (0.5 - anchor.x) * scaledBounds.width
        let yOffset: CGFloat = (scale - 1) * (0.5 - anchor.y) * scaledBounds.height
        offset = .init(
            width: initialOffset.width + xOffset,
            height: initialOffset.height + yOffset
        )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        // noop
        // zoomScale = 1.25
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

private extension UnitPoint {
    func scaled(by factor: CGFloat) -> UnitPoint {
        return .init(x: x * factor, y: y * factor)
    }
}

private extension CGSize {
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
