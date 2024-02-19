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
    let communityId: Int?
    let modPersonId: Int?
    let otherPersonId: Int?
    let page: Int?
    let limit: Int?
    let hideModlogNames: Bool
}
