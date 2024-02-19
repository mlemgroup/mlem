//
//  APIMarkPostAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/MarkPostAsRead.ts
struct APIMarkPostAsRead: Codable {
    let post_id: Int?
    let post_ids: [Int]?
    let read: Bool
}
