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
    
    /// Scale when the previous pinch recognizer finished
    // private var previousScale: CGFloat = 1.0
    
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
        
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.location(in: view)
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        
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
        
        guard let bounds = view?.bounds else {
            assertionFailure("No bounds")
            return
        }
        print("DEBUG xOffset: \((zoomScale - 1) * (0.5 - anchor.x))")
        let xOffset: CGFloat = (zoomScale - 1) * (0.5 - anchor.x) * bounds.width
        let yOffset: CGFloat = (zoomScale - 1) * (0.5 - anchor.y) * bounds.height
        offset = .init(width: xOffset, height: yOffset)
        
        // let scaleFactor: CGFloat = zoomScale / previousScale

//        let translation = translation(of: touches)
//        offset = .init(
//            width: offset.width + translation.width,
//            height: offset.height + translation.height
//        )
            // .scaled(by: scaleFactor)
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
