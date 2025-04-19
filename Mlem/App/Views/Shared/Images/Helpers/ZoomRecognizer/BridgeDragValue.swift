//
//  BridgeDragValue.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-03-31.
//

import Foundation
import UIKit

/// Custom struct to convert UIKit drag information to SwiftUI
struct BridgeDragValue {
    let velocity: CGSize
    let translation: CGSize
    let startLocation: CGPoint
    
    init(velocity: CGSize, translation: CGSize, startLocation: CGPoint) {
        self.velocity = velocity
        self.translation = translation
        self.startLocation = startLocation
    }
    
    init(uiPanGesture: UIPanGestureRecognizer, startLocation: CGPoint?) {
        assert(startLocation != nil, "startLocation was nil")
        let uiVelocity = uiPanGesture.velocity(in: nil)
        let uiTranslation = uiPanGesture.translation(in: nil)
        self.velocity = .init(width: uiVelocity.x, height: uiVelocity.y)
        self.translation = .init(width: uiTranslation.x, height: uiTranslation.y)
        self.startLocation = startLocation ?? .zero
    }
}
