//
//  APIPersonMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PersonMention.ts
struct APIPersonMention: Codable {
    let id: Int
    let recipientId: Int
    let commentId: Int
    let read: Bool
    let published: Date
}
