//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension RegistrationMode {
    init(from mode: PieFedRegistrationMode) {
        self = switch mode {
        case .closed: .closed
        case .open: .open
        case .requireApplication: .requiresApplication
        }
    }
}
