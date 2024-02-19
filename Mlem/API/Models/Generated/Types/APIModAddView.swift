//
//  APIModAddView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModAddView.ts
struct APIModAddView: Codable {
    let modAdd: APIModAdd
    let moderator: APIPerson?
    let moddedPerson: APIPerson
}
