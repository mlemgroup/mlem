//
//  APIInstance.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/Instance.ts
struct APIInstance: Codable {
    let id: Int
    let domain: String
    let published: String
    let updated: String?
    let software: String?
    let version: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "domain", value: domain),
            .init(name: "published", value: published),
            .init(name: "updated", value: updated),
            .init(name: "software", value: software),
            .init(name: "version", value: version)
        ]
    }
}
