//
//  APILoginToken.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/LoginToken.ts
struct APILoginToken: Codable {
    let user_id: Int
    let published: Date
    let ip: String?
    let user_agent: String?
}
