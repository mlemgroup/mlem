//
//  Haptic Manager.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation

class HapticManager {
    
    static let shared = HapticManager()
    
    func lightTap() {
        print("light tap")
    }
    
    private init() {
        print("initializing...")
    }
}
