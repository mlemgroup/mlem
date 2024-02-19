//
//  APIBlockPersonResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/BlockPersonResponse.ts
struct APIBlockPersonResponse: Codable {
    let person_view: APIPersonView
    let blocked: Bool
}
