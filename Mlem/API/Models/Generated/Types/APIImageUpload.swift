//
//  APIImageUpload.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ImageUpload.ts
struct APIImageUpload: Codable {
    let localUserId: Int
    let pictrsAlias: String
    let pictrsDeleteToken: String
    let published: Date
}
