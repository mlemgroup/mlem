//
//  APIModlogListParams.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModlogListParams.ts
struct APIModlogListParams: Codable {
    let community_id: Int?
    let mod_person_id: Int?
    let other_person_id: Int?
    let page: Int?
    let limit: Int?
    let hide_modlog_names: Bool
}
