//
//  APIFederatedInstances.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/FederatedInstances.ts
struct APIFederatedInstances: Codable {
    let linked: [APIInstanceWithFederationState]
    let allowed: [APIInstanceWithFederationState]
    let blocked: [APIInstanceWithFederationState]

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
