//
//  APIMarkPostAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/MarkPostAsRead.ts
struct APIMarkPostAsRead: Codable {
    let post_id: Int?
    let post_ids: [Int]?
    let read: Bool

    func toQueryItems() -> [URLQueryItem] {
        return [

        ]
    }

}
