//
//  Environment+DeployEnvironment.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-04.
//

import Foundation
import SwiftUI

enum DeploymentEnv: Equatable {
    
    enum DistributionChannel: Equatable {
        case appStore, testFlight
        /// `StoreKit` receipt not found.
        case unknown
    }
    
    case production(DistributionChannel)
    /// - Note: Checked against `DEBUG` flag.
    case development
    case simulator
    
    static func current() -> DeploymentEnv {
#if targetEnvironment(simulator)
        return .simulator
#elseif DEBUG
        return .development
#else
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            print("Could not determine distribution channel for current deployment env (.production).")
            return .production(.unknown)
        }
        /// Receipt Path:
        /// App Store builds have path `/receipt`.
        /// TestFlight builds have path `/sandboxReceipt`.
        /// Simulator builds have path `/receipt`.
        /// Development (on-device) builds have path `/sandboxReceipt`
        /// Yes, it *is* possible this may change in a future update. [2023.08]
        let isSandboxEnv = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
        if isSandboxEnv {
            return .production(.testFlight)
        } else {
            return .production(.appStore)
        }
#endif
    }
}

struct DeploymentEnvEnvironmentKey: EnvironmentKey {
    static var defaultValue: DeploymentEnv { .current() }
}

extension EnvironmentValues {
    var deploymentEnv: DeploymentEnv {
        get { self[DeploymentEnvEnvironmentKey.self] }
        set { self[DeploymentEnvEnvironmentKey.self] = newValue }
    }
}
