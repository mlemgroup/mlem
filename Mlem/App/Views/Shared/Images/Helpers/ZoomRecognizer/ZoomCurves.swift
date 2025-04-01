//
//  ZoomCurves.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-28.
//

import Foundation

/// This works like the native UnitCurve
protocol ZoomCurve {
    func value(at progress: Double) -> (Double, active: Bool)
    func velocity(at progress: Double) -> Double
}

class SinusoidalFriction: ZoomCurve {
    func value(at progress: Double) -> (Double, active: Bool) {
        guard progress < 1 else { return (0.5, false) }
        return (((.pi * progress) + sin(.pi * progress)) / (2 * .pi), true)
    }
    
    func velocity(at progress: Double) -> Double {
        guard progress < 1 else { return 0 }
        return (cos(.pi * progress) + 1) / 2
    }
}

/// ZoomCurve that starts with velocity 1, slows, then gently returns to the original position.
/// The underlying curve equation is y = x^3 + x^2.
/// The maximum output value is 1/3 * duration; to maintain a slope of 1 at y = 0, the curve shape is scaled by duration on both axes
class PolynomialBoundBounce: ZoomCurve {
    var duration: Double
    
    init(duration: Double = 1) {
        self.duration = duration
    }
    
    func value(at progress: Double) -> (Double, active: Bool) {
        let scaledProgress: Double = progress / duration
        guard scaledProgress < 1 else { return (0, false) }
        return ((pow(scaledProgress - 1, 3) + pow(scaledProgress - 1, 2)) * duration, true)
    }
    
    func velocity(at progress: Double) -> Double {
        assertionFailure("Not implemented")
        return 0
    }
}

/// ZoomCurve matching the shape of PolynomialBoundBounce, but starting at the furthest point of the bounce (1) and gently returning to 0.
/// The maximum output value is 1; this curve only scales with duration along the x axis.
class PolynomialBoundReset: ZoomCurve {
    var duration: Double
    
    init(duration: Double = 1) {
        self.duration = duration
    }
    
    func value(at progress: Double) -> (Double, active: Bool) {
        let scaledProgress: Double = progress / duration
        guard scaledProgress < 1 else { return (0, false) }
        let base: CGFloat = (2 / 3) * (scaledProgress - 1)
        return ((pow(base, 3) + pow(base, 2)) * 6.75, true)
    }
    
    func velocity(at progress: Double) -> Double {
        assertionFailure("Not implemented")
        return 0
    }
}
