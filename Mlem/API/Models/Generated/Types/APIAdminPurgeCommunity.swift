//
//  APIAdminPurgeCommunity.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/AdminPurgeCommunity.ts
struct APIAdminPurgeCommunity: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let adminPersonId: Int
    let reason: String?
    let when_: String
}
