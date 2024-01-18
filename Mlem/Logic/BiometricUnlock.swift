//
//  BiometricUnlock.swift
//  Mlem
//
//  Created by Sumeet Gill on 2024-01-16.
//

import Foundation
import LocalAuthentication
import SwiftUI

enum BiometricsError: LocalizedError {
    case rejected
    case permissions
    
    var errorDescription: String? {
        switch self {
        case .permissions:
            return "Please check Face ID permissions."
        case .rejected:
            return "Please try again."
        case .unknown:
            return "An unknown error has occured."
        }
    }
}

@MainActor
class BiometricUnlock: ObservableObject {
    @Published var authorizationError: Error?
    @Published var isUnlocked: Bool = false

    func requestAuthentication(onComplete: @escaping (Result<Void, Error>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate to unlock app."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in
                DispatchQueue.main.sync {
                    if success {
                        self.isUnlocked = true
                        onComplete(.success(()))
                    } else {
                        self.isUnlocked = false
                        onComplete(.failure(BiometricsError.rejected))
                    }
                }
            }
        } else {
            isUnlocked = false
            onComplete(.failure(BiometricsError.permissions))
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
