//
//  ApiModBanView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBanView.ts
struct ApiModBanView: Decodable {
    let modBan: ApiModBan
    let moderator: APIPerson?
    let bannedPerson: APIPerson
}
