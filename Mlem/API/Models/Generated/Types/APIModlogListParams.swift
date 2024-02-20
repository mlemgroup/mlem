//
//  APIModlogListParams.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ModlogListParams.ts
struct APIModlogListParams: Codable {
    let communityId: Int?
    let modPersonId: Int?
    let otherPersonId: Int?
    let page: Int?
    let limit: Int?
    let hideModlogNames: Bool
}
