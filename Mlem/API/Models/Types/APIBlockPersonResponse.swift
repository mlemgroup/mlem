//
//  APIBlockPersonResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/BlockPersonResponse.ts
struct APIBlockPersonResponse: Codable {
    let person_view: APIPersonView
    let blocked: Bool
}
