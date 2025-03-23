//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

struct ZoomRecognizer: UIViewRepresentable {

    @Binding var scale: CGFloat
    @Binding var offset: CGPoint

    func updateUIView(_ uiView: UIView, context: Context) {
        print("DEBUG updated")
    }

    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        
        let pinchGesture = PinchRecognizer(
            target: context.coordinator,
            action: nil,
            zoomScale: $scale,
            offset: $offset
        )
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)

        return ret
    }

    func makeCoordinator() -> Coordinator {
        .init(scale: $scale)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @Binding var scale: CGFloat

        init(scale: Binding<CGFloat>) {
            _scale = scale
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer:
                UIGestureRecognizer
        ) -> Bool {
            return true
        }
    }
}

class PinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    @Binding var offset: CGPoint

    /// Scale when the current pinch began
    private var initialScale: CGFloat = 1.0
    
    /// Offset when the current pinch began
    private var initialOffset: CGPoint = .zero

    init(
        target: Any?,
        action: Selector?,
        zoomScale: Binding<CGFloat>,
        offset: Binding<CGPoint>
    ) {
        _zoomScale = zoomScale
        _offset = offset
        super.init(target: target, action: action)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        print("DEBUG touches began")
        initialScale = zoomScale
        initialOffset = offset
        super.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        print("DEBUG touches moved")
        zoomScale = initialScale * scale

        if touches.count == 2 {
            // swiftlint:disable:next shorthand_operator
            offset = offset + translation(of: touches)
        }
        print("DEBUG average location: \(averageLocation(of: touches))")
    }
    
    private func translation(of touches: Set<UITouch>) -> CGPoint {
        let averageLocation: CGPoint = averageLocation(of: touches)
        var previousLocation: CGPoint = .zero
        for touch in touches {
            previousLocation.x += touch.previousLocation(in: view).x
            previousLocation.y += touch.previousLocation(in: view).y
        }
        previousLocation.x /= CGFloat(touches.count)
        previousLocation.y /= CGFloat(touches.count)
        
        return .init(
            x: averageLocation.x - previousLocation.x,
            y: averageLocation.y - previousLocation.y
        )
    }

    private func averageLocation(of touches: Set<UITouch>) -> CGPoint {
        var averageLocation: CGPoint = .zero
        for touch in touches {
            averageLocation.x += touch.location(in: view).x
            averageLocation.y += touch.location(in: view).y
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        return averageLocation
    }
}

private extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}
