//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct FederationPolicy {
    let allowed: Set<String>
    let blocked: Set<String>
    
    init(from federatedInstances: LemmyFederatedInstances) {
        self.allowed = Set(federatedInstances.allowed.map(\.domain))
        self.blocked = Set(federatedInstances.blocked.map(\.domain))
    }
    
    init(from instances: [LemmyFederatedInstanceView]) {
        var allowed: Set<String> = []
        var blocked: Set<String> = []
        for instance in instances {
            if instance.allowed != nil {
                allowed.insert(instance.instance.domain)
            }
            if instance.blocked != nil {
                blocked.insert(instance.instance.domain)
            }
        }
        self.allowed = allowed
        self.blocked = blocked
    }
}
