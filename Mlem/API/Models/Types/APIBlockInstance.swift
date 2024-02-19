//
//  APIBlockInstance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/BlockInstance.ts
struct APIBlockInstance: Codable {
    let instance_id: Int
    let block: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "instance_id", value: String(instance_id)),
            .init(name: "block", value: String(block))
        ]
    }
}
