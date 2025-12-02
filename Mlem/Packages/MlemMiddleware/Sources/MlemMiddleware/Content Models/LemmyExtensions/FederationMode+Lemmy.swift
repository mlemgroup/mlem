//
//  FederationMode+Lemmy.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-11-30.
//

import Foundation

extension FederationMode {
    init(from federationMode: LemmyFederationMode) {
        self = switch federationMode {
        case .all: .all
        case .local: .local
        case .disable: .disable
        }
    }
}
