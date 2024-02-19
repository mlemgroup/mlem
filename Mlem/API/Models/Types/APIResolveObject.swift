//
//  APIResolveObject.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ResolveObject.ts
struct APIResolveObject: Codable {
    // swiftlint:disable:next identifier_name
    let q: String

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "q", value: q)
        ]
    }

}
