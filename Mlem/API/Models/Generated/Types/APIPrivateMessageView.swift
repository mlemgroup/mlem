//
//  APIPrivateMessageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PrivateMessageView.ts
struct APIPrivateMessageView: Codable {
    let privateMessage: APIPrivateMessage
    let creator: APIPerson
    let recipient: APIPerson
}
