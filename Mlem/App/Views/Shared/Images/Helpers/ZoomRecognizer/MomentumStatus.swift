//
//  MomentumStatus.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-28.
//

import Foundation

/// Tracks the current momentum and computes position based on time
class MomentumStatus {
    private let boundResetDuration: Double = 0.3
    let bounds: CGSize
    
    var xt0: CFTimeInterval?
    private var xv0: CGFloat
    private(set) var xOob: Bool = false
    private var xUnitCurve: any ZoomCurve
    
    var yt0: CFTimeInterval?
    private var yv0: CGFloat
    private(set) var yOob: Bool = false
    private var yUnitCurve: any ZoomCurve
    
    init(initialVelocity: CGPoint, bounds: CGSize, xOob: Bool, yOob: Bool) {
        self.xv0 = initialVelocity.x
        self.xOob = xOob
        self.xUnitCurve = xOob ? PolynomialBoundReset(duration: 0.25) : SinusoidalFriction()
        
        self.yv0 = initialVelocity.y
        self.yOob = yOob
        self.yUnitCurve = yOob ? PolynomialBoundReset(duration: 0.25) : SinusoidalFriction()
        
        self.bounds = bounds
    }
    
    func position(at time: CFTimeInterval) -> (CGSize, active: Bool) {
        guard let xt0, let yt0 else {
            assertionFailure("Tried to query position before setting t0s")
            return (position: .zero, active: false)
        }
        
        let (xPosition, xActive) = xUnitCurve.value(at: time - xt0)
        let (yPosition, yActive) = yUnitCurve.value(at: time - yt0)
        
        return (
            .init(width: xPosition * xv0, height: yPosition * yv0),
            xActive || yActive
        )
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
        xUnitCurve = PolynomialBoundBounce(duration: boundResetDuration)
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
        yUnitCurve = PolynomialBoundBounce(duration: boundResetDuration)
    }
}
