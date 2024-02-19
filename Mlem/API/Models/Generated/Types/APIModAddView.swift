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
    let mod_add: APIModAdd
    let moderator: APIPerson?
    let modded_person: APIPerson
}
