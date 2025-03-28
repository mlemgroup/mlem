//
//  ZoomCurves.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-28.
//

import Foundation

/// This works like the native UnitCurve
protocol ZoomCurve {
    func value(at: Double) -> (Double, active: Bool)
    func velocity(at: Double) -> Double
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

/// ZoomCurve that starts with velocity 1, slows, then gently returns to the original position
/// The underlying curve equation is y = x^3 + x^2
class PolynomialBoundReset: ZoomCurve {
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
        guard progress < 1 else { return 0 }
        return 3 * (pow(progress - 1, 2)) + 2 * (progress - 1)
    }
}
