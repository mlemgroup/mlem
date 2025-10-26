//
//  ZoomRecognizerCoordinator.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-30.
//

import SwiftUI
import UIKit
import os

enum PanType {
    case move, zoom, custom, none
}

class ZoomRecognizerCoordinator: NSObject, UIGestureRecognizerDelegate {
    private let log: Logger = .mlemLogger(subsystem: "Mlem")
    
    @Setting(\.a11y_zoomSliderLocation) var zoomSliderLocation
    
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    
    let customDragMoved: ((BridgeDragValue) -> Void)?
    let customDragEnded: (() -> Void)?
    let customTap: (() -> Void)?
    
    /// Scale when the current gesture began
    var initialScale: CGFloat = 1.0
    
    /// Offset when the current gesture began
    var initialOffset: CGSize = .zero
    
    /// Point in the image where the zoom gesture is anchored
    var anchor: UnitPoint = .center
    
    var link: CADisplayLink?
    var momentum: MomentumStatus?
    
    /// Bounds of the view
    var bounds: CGSize?
    
    var panType: PanType = .none
    
    var customPanStartLocation: CGPoint?
    
    /// Computes the maximum allowed offsets for a given scale.
    /// - Note: to get the minimum offset, multiply the return value by -1.
    lazy var maxOffsets: CachedComputation<CGFloat, CGSize> = .init { input in
        guard let bounds = self.bounds else {
            assertionFailure("No bounds")
            return .zero
        }
        return bounds.scaled(by: (input - 1) / 2)
    }
    
    let leftZoomSliderHitbox: CGRect = .init(
        origin: .init(x: 0, y: 70),
        size: .init(width: 40, height: UIScreen.main.bounds.height - 140)
    )
    let rightZoomSliderHitbox: CGRect = .init(
        origin: .init(x: UIScreen.main.bounds.width - 40, y: 70),
        size: .init(width: 40, height: UIScreen.main.bounds.height - 140)
    )
    
    init(
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        customDragMoved: ((BridgeDragValue) -> Void)? = nil,
        customDragEnded: (() -> Void)? = nil,
        customTap: (() -> Void)? = nil
    ) {
        _scale = scale
        _offset = offset
        self.customDragMoved = customDragMoved
        self.customDragEnded = customDragEnded
        self.customTap = customTap
    }
    
    @objc
    func handlePinch(gesture: PanningPinchRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            guard let view = gesture.view else {
                assertionFailure("No view")
                return
            }
            initializeBounds(view: view)
            resetMomentum()
            beginPinch(at: gesture.location(in: view))
        case .changed:
            updatePinch(with: gesture.scale, panOffset: gesture.panOffset)
        case .ended, .cancelled:
            endPinch(gesture: gesture)
        case .failed:
            log.debug("Pinch gesture failed")
        default:
            assertionFailure("Unknown state")
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch panType {
        case .move:
            handleMovePan(gesture: gesture)
        case .zoom:
            handleZoomPan(gesture: gesture)
        case .custom:
            handleCustomPan(gesture: gesture)
        case .none:
            assertionFailure("Pan started with no valid pan type")
        }
    }
    
    @objc
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else {
            assertionFailure("No view")
            return
        }
        initializeBounds(view: view)
        
        guard let bounds else {
            assertionFailure("No bounds")
            return
        }
        
        initialOffset = offset
        initialScale = scale
        
        let targetZoomScale: CGFloat
        let newOffset: CGSize
        if scale == 1 {
            let location = gesture.location(in: view)
            targetZoomScale = 3
            anchor = .init(x: location.x / bounds.width, y: location.y / bounds.height)
            let offsetDeltas = computeOffsetDeltas(scaleFactor: targetZoomScale / initialScale)
            let maxOffsets = maxOffsets.compute(targetZoomScale)
            
            newOffset = .init(
                width: (initialOffset.width + offsetDeltas.width).bounded(lower: -maxOffsets.width, upper: maxOffsets.width),
                height: (initialOffset.height + offsetDeltas.height).bounded(lower: -maxOffsets.height, upper: maxOffsets.height)
            )
        } else {
            targetZoomScale = 1
            anchor = .center
            newOffset = .zero
        }
        
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = newOffset
            scale = targetZoomScale
        }
    }
    
    @objc
    func handleSingleTap(gesture: MomentumResetTapGestureRecognizer) {
        initializeBounds(view: gesture.view)

        let maxOffsets = maxOffsets.compute(scale)
        if abs(offset.width) > maxOffsets.width || abs(offset.height) > maxOffsets.height {
            resetToBounds(activeOffset: offset - initialOffset)
        }
        
        if gesture.momentumKilled {
            gesture.momentumKilled = false
        } else if let customTap {
            customTap()
        }
    }
}
