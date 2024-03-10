//
//  ApiAdminPurgePerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePerson.ts
struct ApiAdminPurgePerson: Codable {
    let id: Int
    let adminPersonId: Int
    let reason: String?
    let when_: String
}
