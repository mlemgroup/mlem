//
//  APIReadableFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ReadableFederationState.ts
struct APIReadableFederationState: Codable {
    let instance_id: Int
    let last_successful_id: Int?
    let last_successful_published_time: String?
    let fail_count: Int
    let last_retry: String?
    let next_retry: String?
}
