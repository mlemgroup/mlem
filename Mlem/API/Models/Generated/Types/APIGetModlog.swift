//
//  APIGetModlog.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// GetModlog.ts
struct APIGetModlog: Codable {
    let modPersonId: Int?
    let communityId: Int?
    let page: Int?
    let limit: Int?
    let type_: APIModlogActionType?
    let otherPersonId: Int?
}
