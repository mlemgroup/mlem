//
//  BiometricUnlock.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import Foundation
import LocalAuthentication
import SwiftUI

actor BiometricUnlockState {
    var isUnlocked: Bool = false

    func getUnlockStatus() async -> Bool {
        isUnlocked
    }
        
    func setUnlockStatus(isUnlocked: Bool) {
        self.isUnlocked = isUnlocked
        print("SETTING UNLOCK STATUS TO \(isUnlocked) YO: \(self.isUnlocked)")
    }
}

class BiometricUnlock: ObservableObject {
    @Published var authorizationError: Error?
    
    func requestAuthentication(onComplete: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock app."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                if success {
                    BiometricUnlockState().setUnlockStatus(isUnlocked: true)
                    onComplete(true, error)
//                    print("APP LOCK STATUS END YO 1 SUCCESS: \(BiometricUnlockState().getUnlockStatus())")
                } else {
                    BiometricUnlockState().setUnlockStatus(isUnlocked: false)
                    onComplete(false, error)
//                    print("APP LOCK STATUS END YO 2 FAIL: \(BiometricUnlockState().getUnlockStatus())")
                }
            }
        } else {
            Task {
                await BiometricUnlockState().setUnlockStatus(isUnlocked: false)
                await print("APP LOCK STATUS END YO 3: \(BiometricUnlockState().getUnlockStatus())")
            }
            onComplete(false, error)
        }
    }
    
    func requestBiometricPermissions() -> Bool {
        var error: NSError?
        var context = LAContext()
        
        let isBioMetricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error {
            print("Biometrics error: \(error.localizedDescription)")
        }
        
        return isBioMetricsAvailable
    }
}
