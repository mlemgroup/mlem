//
//  MomentumStatus.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-28.
//

import Foundation

/// Tracks the current momentum and computes position based on time
class MomentumStatus {
    var xt0: CFTimeInterval?
    var xv0: CGFloat
    var xOob: Bool = false
    
    var xUnitCurve: any ZoomCurve = SinusoidalFriction()
    
    var yt0: CFTimeInterval?
    var yv0: CGFloat
    var yOob: Bool = false
    
    var yUnitCurve: any ZoomCurve = SinusoidalFriction()
    
    init(initialVelocity: CGPoint) {
        self.xv0 = initialVelocity.x
        self.yv0 = initialVelocity.y
    }
    
    func xPosition(at time: CFTimeInterval) -> CGFloat {
        guard let xt0 else {
            assertionFailure("Tried to query position before setting xt0")
            return .zero
        }
        return xUnitCurve.value(at: time - xt0) * xv0
    }
    
    func xLeftBounds(at time: CFTimeInterval) {
        guard !xOob else {
            assertionFailure("x left bounds twice")
            return
        }
        guard let xt0 else {
            assertionFailure("x left bounds with no xt0")
            return
        }
        xOob = true
        xv0 = xUnitCurve.velocity(at: time - xt0) * xv0
        self.xt0 = time
        xUnitCurve = PolynomialBoundReset()
    }
    
    func yPosition(at time: CFTimeInterval) -> CGFloat {
        guard let yt0 else {
            assertionFailure("Tried to query position before setting yt0")
            return .zero
        }
        return yUnitCurve.value(at: time - yt0) * yv0
    }
    
    func yLeftBounds(at time: CFTimeInterval) {
        guard !yOob else {
            assertionFailure("y left bounds twice")
            return
        }
        guard let yt0 else {
            assertionFailure("y left bounds with no yt0")
            return
        }
        yOob = true
        yv0 = yUnitCurve.velocity(at: time - yt0) * yv0
        self.yt0 = time
        yUnitCurve = PolynomialBoundReset()
    }
}
