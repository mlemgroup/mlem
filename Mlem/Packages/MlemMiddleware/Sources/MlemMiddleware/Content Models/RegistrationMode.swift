//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum RegistrationMode {
    case closed, open, requiresApplication
    
    init(from mode: LemmyRegistrationMode) {
        self = switch mode {
        case .closed: .closed
        case .requireApplication: .requiresApplication
        case .open: .open
        }
    }
    
    var apiType: LemmyRegistrationMode {
        switch self {
        case .closed: .closed
        case .open: .open
        case .requiresApplication: .requireApplication
        }
    }
}
