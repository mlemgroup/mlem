//
//  APIDeleteCustomEmoji.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/DeleteCustomEmoji.ts
struct APIDeleteCustomEmoji: Codable {
    let id: Int

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "id", value: String(id))
        ]
    }

}
