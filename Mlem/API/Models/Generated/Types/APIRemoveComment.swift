//
//  APIRemoveComment.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/RemoveComment.ts
struct APIRemoveComment: Codable {
    let commentId: Int
    let removed: Bool
    let reason: String?
}
