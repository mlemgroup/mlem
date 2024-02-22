//
//  ApiReadableFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ReadableFederationState.ts
struct ApiReadableFederationState: Codable {
    let instanceId: Int
    let lastSuccessfulId: Int?
    let lastSuccessfulPublishedTime: String?
    let failCount: Int
    let lastRetry: String?
    let nextRetry: String?
}
