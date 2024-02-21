//
//  ApiFederatedInstances.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// FederatedInstances.ts
struct ApiFederatedInstances: Codable {
    let linked: [ApiInstanceWithFederationState]
    let allowed: [ApiInstanceWithFederationState]
    let blocked: [ApiInstanceWithFederationState]
}
