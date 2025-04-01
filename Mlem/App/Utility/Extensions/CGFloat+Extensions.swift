//
//  CGFloat+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-17.
//

import Foundation

extension CGFloat {
    func bounded(lower: CGFloat, upper: CGFloat) -> CGFloat {
        if self < lower {
            return lower
        }
        if self > upper {
            return upper
        }
        return self
    }
    
    func stepped(by increment: CGFloat) -> CGFloat {
        (self / increment).rounded() * increment
    }
    
    /// Returns the value of this CGFloat bounded within the given range. If this float is above softMax, the returned
    /// value will asymptotically approach hardMax, and likewise for softMin and hardMin
    func softBounded(softMin: CGFloat, hardMin: CGFloat, softMax: CGFloat, hardMax: CGFloat) -> CGFloat {
        guard softMin > hardMin, softMax < hardMax, softMin < softMax else {
            if softMin <= hardMin {
                assertionFailure("Soft min \(softMin) <= hard min \(hardMin)")
            }
            if softMax >= hardMax {
                assertionFailure("Soft max \(softMax) >= hard max \(hardMax)")
            }
            if softMin >= softMax {
                assertionFailure("Soft min \(softMin) >= soft max \(softMax)")
            }
            return self
        }
        
        if self > softMax {
            let headroom = hardMax - softMax
            let excess = self - softMax
            let scaledExcess = headroom - asymptote(x: excess, n: headroom)
            return softMax + scaledExcess
        }
        
        if self < softMin {
            let headroom = softMin - hardMin
            let excess = softMin - self
            let scaledExcess = asymptote(x: excess, n: headroom) - headroom
            return softMin + scaledExcess
        }
        
        return self
    }
    
    /// Base asymptotic function used for softBounded, where x is the value to scale and n is the asymptotic bound
    private func asymptote(x: CGFloat, n: CGFloat) -> CGFloat { // swiftlint:disable:this identifier_name
        n / (((1 / n) * x) + 1)
    }
}
