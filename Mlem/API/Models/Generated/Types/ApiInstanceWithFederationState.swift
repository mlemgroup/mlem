//
//  ApiInstanceWithFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// InstanceWithFederationState.ts
struct ApiInstanceWithFederationState: Codable {
    let id: Int
    let domain: String
    let published: Date
    let updated: Date?
    let software: String?
    let version: String?
    let federationState: ApiReadableFederationState?
}
