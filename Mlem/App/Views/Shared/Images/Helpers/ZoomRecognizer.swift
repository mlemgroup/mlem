//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

struct ZoomRecognizer: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
        print("DEBUG updated")
    }
    
    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        ret.backgroundColor = .red

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.minimumNumberOfTouches = 2
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(gesture:))
        )
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)
        
        return ret
    }
    
    func makeCoordinator() -> Coordinator {
        .init()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }
        
        @objc
        func handlePinch(gesture: UIPinchGestureRecognizer) {
            // print("DEBUG pinch \(gesture.scale)")
        }
        
        @objc
        func handlePan(gesture: UIPanGestureRecognizer) {
            guard let frame = gesture.view?.frame else { return }
            
            let location = gesture.location(in: nil)
            print("DEBUG pan \(location), \(location.x), \(location.x / frame.width)")
        }
    }
}
