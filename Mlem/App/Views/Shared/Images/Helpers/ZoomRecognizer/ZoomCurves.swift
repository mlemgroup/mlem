//
//  ZoomCurves.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-28.
//

import Foundation

/// This works like the native UnitCurve
protocol ZoomCurve {
    func value(at: Double) -> Double
    func velocity(at: Double) -> Double
}

class SinusoidalFriction: ZoomCurve {
    func value(at progress: Double) -> Double {
        guard progress < 1 else { return 1 }
        return ((.pi * progress) + sin(.pi * progress)) / .pi
    }
    
    func velocity(at progress: Double) -> Double {
        guard progress < 1 else { return 0 }
        return (cos(.pi * progress) + 1) / 2
    }
}

/// ZoomCurve that starts with velocity 1, slows, then gently returns to the original position
/// The underlying curve equation is y = x^3 + x^2
class PolynomialBoundReset: ZoomCurve {
    func value(at progress: Double) -> Double {
        guard progress < 1 else {
            return 0
        }
        return pow(progress - 1, 3) + pow(progress - 1, 2)
    }
    
    func velocity(at progress: Double) -> Double {
        guard progress < 1 else { return 0 }
        return 3 * (pow(progress - 1, 2)) + 2 * (progress - 1)
    }
}
