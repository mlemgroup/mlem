//
//  ApiMarkPostAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// MarkPostAsRead.ts
struct ApiMarkPostAsRead: Codable {
    let postId: Int
    let read: Bool
    let postIds: [Int]?
}
