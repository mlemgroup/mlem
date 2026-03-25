//
//  PanGesture.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2024.
//

import SwiftUI

struct PanGesture: UIGestureRecognizerRepresentable {
    /// If provided, the gesture will not register within `leadingBuffer` px of the leading edge
    let leadingBuffer: CGFloat?
    var handle: (UIPanGestureRecognizer) -> Void
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { .init(leadingBuffer: leadingBuffer) }
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.delegate = context.coordinator
        gesture.isEnabled = true
        return gesture
    }
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        let leadingBuffer: CGFloat
        
        init(leadingBuffer: CGFloat?) {
            self.leadingBuffer = leadingBuffer ?? 0
        }
        
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            
            // prevent swipe from interfering with interactive swipe back
            guard panRecognizer.location(in: gestureRecognizer.view).x >= leadingBuffer else { return false }

            let velocity = panRecognizer.velocity(in: gestureRecognizer.view)
            return abs(velocity.y) < abs(velocity.x)
        }
    }
}
