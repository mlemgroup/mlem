//
//  APIRemovePost.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/RemovePost.ts
struct APIRemovePost: Codable {
    let post_id: Int
    let removed: Bool
    let reason: String?
}
