//
//  Recognizers.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-30.
//

import UIKit
import SwiftUICore

class MomentumResetTapGestureRecognizer: UITapGestureRecognizer {
    var resetMomentum: () -> Void
    
    init(target: Any?, action: Selector?, resetMomentum: @escaping () -> Void) {
        self.resetMomentum = resetMomentum
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        resetMomentum()
        super.touchesBegan(touches, with: event)
    }
}

class PanningPinchRecognizer: UIPinchGestureRecognizer {
    @Binding var zoomScale: CGFloat
    var panOffset: CGSize = .zero
    
    init(target: Any?, action: Selector?, zoomScale: Binding<CGFloat>) {
        _zoomScale = zoomScale
        super.init(target: target, action: action)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard state == .began || state == .changed else { return }
        let translation = translation(of: touches)
        panOffset += translation.scaled(by: zoomScale)
    }
    
    private func translation(of touches: Set<UITouch>) -> CGSize {
        var averageLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.location(in: view)
        }
        averageLocation.x /= CGFloat(touches.count)
        averageLocation.y /= CGFloat(touches.count)
        
        var previousLocation: CGPoint = touches.reduce(into: .zero) { result, touch in
            result += touch.previousLocation(in: view)
        }
        previousLocation.x /= CGFloat(touches.count)
        previousLocation.y /= CGFloat(touches.count)
        
        return .init(
            width: averageLocation.x - previousLocation.x,
            height: averageLocation.y - previousLocation.y
        )
    }
}
