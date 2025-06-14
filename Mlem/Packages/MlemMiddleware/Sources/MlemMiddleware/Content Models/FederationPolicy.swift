//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct FederationPolicy {
    let linked: Set<String>
    let allowed: Set<String>
    let blocked: Set<String>
    
    init(from federatedInstances: ApiFederatedInstances) {
        self.linked = Set(federatedInstances.linked.map(\.domain))
        self.allowed = Set(federatedInstances.allowed.map(\.domain))
        self.blocked = Set(federatedInstances.blocked.map(\.domain))
    }
}
