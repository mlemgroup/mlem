//
//  APIModAddView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModAddView.ts
struct APIModAddView: Codable {
    let mod_add: APIModAdd
    let moderator: APIPerson?
    let modded_person: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
