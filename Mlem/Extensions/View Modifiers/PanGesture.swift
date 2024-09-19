//
//  PanGesture.swift
//  Mlem
//
//  Created by Sjmarf on 17/09/2024.
//

import SwiftUI

@available(iOS 18.0, *)
struct PanGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> Void

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { .init() }

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
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }

            let velocity = panRecognizer.velocity(in: gestureRecognizer.view)
            return abs(velocity.y) < abs(velocity.x)
        }
    }
}
