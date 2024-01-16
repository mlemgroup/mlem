//
//  BiometricUnlock.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import Foundation
import LocalAuthentication
import SwiftUI

class BiometricUnlock: ObservableObject {
    @Published var isUnlocked: Bool = false
    @Published var authorizationError: Error?
    
    func requestUnlock() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock app."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.sync {
                    if success {
                        self.isUnlocked = true
                    } else {
                        print("Error unlocking: \(String(describing: error))")
                        self.authorizationError = error
                        self.isUnlocked = false
                    }
                }
            }
        }
    }
}
