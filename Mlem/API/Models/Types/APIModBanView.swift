//
//  APIModBanView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ModBanView.ts
struct APIModBanView: Codable {
    let mod_ban: APIModBan
    let moderator: APIPerson?
    let banned_person: APIPerson

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}
