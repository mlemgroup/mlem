//
//  APIReadableFederationState.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ReadableFederationState.ts
struct APIReadableFederationState: Codable {
    let instance_id: Int
    let last_successful_id: Int?
    let last_successful_published_time: String?
    let fail_count: Int
    let last_retry: String?
    let next_retry: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "instance_id", value: String(instance_id)),
            .init(name: "last_successful_id", value: last_successful_id.map(String.init)),
            .init(name: "last_successful_published_time", value: last_successful_published_time),
            .init(name: "fail_count", value: String(fail_count)),
            .init(name: "last_retry", value: last_retry),
            .init(name: "next_retry", value: next_retry)
        ]
    }
}
