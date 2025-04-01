//
//  ZoomRecognizerCoordinator+GestureRecognition.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

import UIKit

extension ZoomRecognizerCoordinator {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if let doubleTap = gestureRecognizer as? UITapGestureRecognizer {
            if doubleTap.numberOfTapsRequired == 2, otherGestureRecognizer is UIPanGestureRecognizer {
                // prevents quick pan gestures from triggering as double tap
                return false
            }
            return true
        }
        return false
    }
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // single tap should require double tap to fail unless it killed momentum
        if let momentumResetGesture = gestureRecognizer as? MomentumResetTapGestureRecognizer,
           !momentumResetGesture.momentumKilled,
           let doubleTap = otherGestureRecognizer as? UITapGestureRecognizer,
           doubleTap.numberOfTapsRequired == 2 {
            return true
        }
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer || gestureRecognizer is UITapGestureRecognizer {
            return true
        } else if gestureRecognizer is UIPanGestureRecognizer {
            let location = gestureRecognizer.location(in: nil)
            if gestureRecognizer.numberOfTouches == 1 {
                if zoomSliderLocation.leftEnabled && leftZoomSliderHitbox.contains(location) ||
                    zoomSliderLocation.rightEnabled && rightZoomSliderHitbox.contains(location) {
                    panType = .zoom
                    return true
                } else if scale > 1.0 {
                    panType = .move
                    return true
                } else {
                    panType = .custom
                    return true
                }
            }
            return false
        } else {
            return false
        }
    }
}
