//
//  APIModBanView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModBanView.ts
struct APIModBanView: Codable {
    let mod_ban: APIModBan
    let moderator: APIPerson?
    let banned_person: APIPerson
}
