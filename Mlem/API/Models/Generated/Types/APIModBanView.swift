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
    let modBan: APIModBan
    let moderator: APIPerson?
    let bannedPerson: APIPerson
}
