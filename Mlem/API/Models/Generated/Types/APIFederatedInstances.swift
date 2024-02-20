//
//  APIFederatedInstances.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// FederatedInstances.ts
struct APIFederatedInstances: Codable {
    let linked: [APIInstanceWithFederationState]
    let allowed: [APIInstanceWithFederationState]
    let blocked: [APIInstanceWithFederationState]
}
