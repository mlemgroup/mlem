//
//  ApiModBanView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBanView.ts
struct ApiModBanView: Decodable {
    let mod_ban: ApiModBan
    let moderator: APIPerson?
    let banned_person: APIPerson
}
