//
//  APIAdminPurgePersonView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// AdminPurgePersonView.ts
struct APIAdminPurgePersonView: Decodable {
    let adminPurgePerson: APIAdminPurgePerson
    let admin: APIPerson?
}
