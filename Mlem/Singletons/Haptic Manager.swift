//
//  Haptic Manager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

class HapticManager {
    
    let tapper: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    static let shared = HapticManager()
    
    func lightTap() {
        tapper.impactOccurred()
    }
    
    private init() {
        print("initializing...")
    }
}
