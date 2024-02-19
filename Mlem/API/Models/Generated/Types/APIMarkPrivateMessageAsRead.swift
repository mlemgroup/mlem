//
//  APIMarkPrivateMessageAsRead.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/MarkPrivateMessageAsRead.ts
struct APIMarkPrivateMessageAsRead: Codable {
    let private_message_id: Int
    let read: Bool
}
