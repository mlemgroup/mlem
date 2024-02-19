//
//  APILoginToken.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/LoginToken.ts
struct APILoginToken: Codable {
    let userId: Int
    let published: Date
    // swiftlint:disable:next identifier_name
    let ip: String?
    let userAgent: String?
}
