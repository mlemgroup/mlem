//
//  ZoomRecognizer.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-22.
//

import SwiftUI

// TODO: LIST
// - Optimize
//   - Investigate CGAffineTransform instead of scaleEffect + offset

struct ZoomRecognizer: UIViewRepresentable {
    typealias Coordinator = ZoomRecognizerCoordinator

    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var deviceOrientation: UIDeviceOrientation
    
    let customDragMoved: ((BridgeDragValue) -> Void)?
    let customDragEnded: (() -> Void)?
    let customTap: (() -> Void)?
        
    init(
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        deviceOrientation: Binding<UIDeviceOrientation>,
        customDragMoved: ((BridgeDragValue) -> Void)? = nil,
        customDragEnded: (() -> Void)? = nil,
        customTap: (() -> Void)? = nil
    ) {
        self._scale = scale
        self._offset = offset
        self._deviceOrientation = deviceOrientation
        self.customDragMoved = customDragMoved
        self.customDragEnded = customDragEnded
        self.customTap = customTap
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // noop
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
        
        let doubleTap = UITapGestureRecognizer(
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
        .init(
            scale: $scale,
            offset: $offset,
            deviceOrientation: $deviceOrientation,
            customDragMoved: customDragMoved,
            customDragEnded: customDragEnded,
            customTap: customTap
        )
    }
}
