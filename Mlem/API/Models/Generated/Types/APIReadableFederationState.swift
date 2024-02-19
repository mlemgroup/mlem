//
//  APIReadableFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/ReadableFederationState.ts
struct APIReadableFederationState: Codable {
    let instanceId: Int
    let lastSuccessfulId: Int?
    let lastSuccessfulPublishedTime: String?
    let failCount: Int
    let lastRetry: String?
    let nextRetry: String?
}
