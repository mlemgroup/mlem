//
//  APIModBanView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModBanView.ts
struct APIModBanView: Decodable {
    let modBan: APIModBan
    let moderator: APIPerson?
    let bannedPerson: APIPerson
}
