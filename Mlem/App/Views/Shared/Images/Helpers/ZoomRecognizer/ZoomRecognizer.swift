//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

// TODO LIST
// - Precompute offset for double tap to avoid unnecessary motion
// - Zoom slider OOB handling
// - Fix drag + onTap conflicts
// - Optimize
//   - Cache bounds more efficiently, including scaled bounds
//   - Investigate CGAffineTransform instead of scaleEffect + offset

struct ZoomRecognizer: UIViewRepresentable {
    typealias Coordinator = ZoomRecognizerCoordinator

    @Binding var scale: CGFloat
    @Binding var offset: CGSize
        
    init(scale: Binding<CGFloat>, offset: Binding<CGSize>) {
        _scale = scale
        _offset = offset
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if context.coordinator.bounds == nil, uiView.bounds != .zero {
            context.coordinator.initializeBounds(view: uiView)
        }
    }

    func makeUIView(context: Context) -> UIView {
        let ret: UIView = .init()
        
        let pinchGesture = PanningPinchRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePinch(gesture:)),
            zoomScale: $scale
        )
        pinchGesture.delegate = context.coordinator
        ret.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(gesture:))
        )
        panGesture.delegate = context.coordinator
        ret.addGestureRecognizer(panGesture)
        
        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(gesture:))
        )
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = context.coordinator
        ret.addGestureRecognizer(doubleTap)
        
        let singleTap: UITapGestureRecognizer = MomentumResetTapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSingleTap(gesture:)),
            resetMomentum: context.coordinator.resetMomentum
        )
        singleTap.delegate = context.coordinator
        ret.addGestureRecognizer(singleTap)
        
        return ret
    }
    
    func makeCoordinator() -> Coordinator {
        .init(scale: $scale, offset: $offset)
    }
}

extension CGFloat {
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

private extension UnitPoint {
    func scaled(by factor: CGFloat) -> UnitPoint {
        return .init(x: x * factor, y: y * factor)
    }
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func - (lhs: Self, rhs: Self) -> Self {
        .init(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    func scaled(by factor: CGFloat) -> CGSize {
        return .init(width: width * factor, height: height * factor)
    }
}

extension CGPoint {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}
