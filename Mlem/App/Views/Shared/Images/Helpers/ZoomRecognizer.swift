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
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        zoomScale = initialScale * scale

        if touches.count == 2 {
            let translation = translation(of: touches)
            offset = .init(
                width: offset.width + translation.width,
                height: offset.height + translation.height
            )
        }
    }
    
    private func translation(of touches: Set<UITouch>) -> CGSize {
        // let averageLocation: CGPoint = averageLocation(of: touches)
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

private extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
