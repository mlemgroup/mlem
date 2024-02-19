//
//  APIModAdd.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ModAdd.ts
struct APIModAdd: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let removed: Bool
    let when_: String
}
