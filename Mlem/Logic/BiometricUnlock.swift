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
        
    func setUnlockStatus(isUnlocked: Bool) async {
        self.isUnlocked = isUnlocked
    }
}

enum BiometricsError: Error {
    case unknown
    case rejected
    case permissions
}

@MainActor
class BiometricUnlock: ObservableObject {
    @Published var authorizationError: Error?
    
    func requestAuthentication(onComplete: @escaping (Result<Void, Error>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock app."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                if success {
                    Task {
                        await BiometricUnlockState().setUnlockStatus(isUnlocked: true)
                        onComplete(.success(()))
                    }
                } else {
                    Task {
                        await BiometricUnlockState().setUnlockStatus(isUnlocked: false)
                        onComplete(.failure(BiometricsError.rejected))
                    }
                }
            }
        } else {
            Task {
                await BiometricUnlockState().setUnlockStatus(isUnlocked: false)
                onComplete(.failure(BiometricsError.permissions))
            }
        }
    }
    
    func requestBiometricPermissions() -> Bool {
        var error: NSError?
        let context = LAContext()
        
        let isBioMetricsAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error {
            print("Biometrics error: \(error.localizedDescription)")
        }
        
        return isBioMetricsAvailable
    }
}
