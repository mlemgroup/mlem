//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension RegistrationMode {
    init(from mode: LemmyRegistrationMode) {
        self = switch mode {
        case .closed: .closed
        case .requireApplication: .requiresApplication
        case .requireInvitation: .requiresInvitation
        case .open: .open
        }
    }
    
    var apiType: LemmyRegistrationMode {
        switch self {
        case .closed: .closed
        case .open: .open
        case .requiresApplication: .requireApplication
        case .requiresInvitation: .requireInvitation
        }
    }
}
