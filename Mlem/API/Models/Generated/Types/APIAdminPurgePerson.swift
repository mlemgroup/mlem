//
//  APIAdminPurgePerson.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/AdminPurgePerson.ts
struct APIAdminPurgePerson: Codable {
    let id: Int
    let admin_person_id: Int
    let reason: String?
    let when_: String
}
