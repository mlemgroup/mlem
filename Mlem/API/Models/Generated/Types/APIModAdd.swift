//
//  APIModAdd.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModAdd.ts
struct APIModAdd: Codable {
    let id: Int
    let mod_person_id: Int
    let other_person_id: Int
    let removed: Bool
    let when_: String
}
