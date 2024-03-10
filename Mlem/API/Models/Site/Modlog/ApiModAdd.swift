//
//  ApiModAdd.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// ModAdd.ts
struct ApiModAdd: Decodable {
    let id: Int
    let modPersonId: Int
    let otherPersonId: Int
    let removed: Bool
    let when_: String
}
