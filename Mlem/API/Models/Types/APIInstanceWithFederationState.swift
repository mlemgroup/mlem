//
//  APIInstanceWithFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/InstanceWithFederationState.ts
struct APIInstanceWithFederationState: Codable {
    let id: Int
    let domain: String
    let published: String
    let updated: String?
    let software: String?
    let version: String?
    let federation_state: APIReadableFederationState?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
