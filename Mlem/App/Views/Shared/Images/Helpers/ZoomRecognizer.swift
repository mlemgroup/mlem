//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

struct ZoomRecognizer: UIViewRepresentable {
    
    @Binding var scale: CGFloat
    @Binding var anchor: UnitPoint
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("DEBUG updated")
    }
    
    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
        let pinchGesture = PinchRecognizer(
            target: context.coordinator,
            action: nil,
            zoomScale: $scale,
            anchor: $anchor
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
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
        
//        @objc
//        func handlePinch(gesture: UIPinchGestureRecognizer) {
//            scale += gesture.scale
//        }
        
        @objc
        func handlePan(gesture: UIPanGestureRecognizer) {
            guard let frame = gesture.view?.frame else { return }
            
            let location = gesture.location(in: nil)
            print("DEBUG pan \(location), \(location.x), \(location.x / frame.width)")
        }
    }
}

class PinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    @Binding var anchor: UnitPoint
    
    /// Scale when the current pinch began
    private var initialScale: CGFloat = 1.0
    
    init(
        target: Any?,
        action: Selector?,
        zoomScale: Binding<CGFloat>,
        anchor: Binding<UnitPoint>
    ) {
        _zoomScale = zoomScale
        _anchor = anchor
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        print("DEBUG touches began")
        initialScale = zoomScale
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        print("DEBUG touches moved")
        zoomScale = initialScale * scale
        
        if touches.count == 2, let bounds = view?.bounds {
            let averageLocation = averageLocation(of: touches)
            anchor = .init(
                x: (1 - (averageLocation.x / bounds.width)) / zoomScale,
                y: (1 - (averageLocation.y / bounds.height)) / zoomScale
            )
        }
        print("DEBUG average location: \(averageLocation(of: touches))")
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
