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
    let local_user_id: Int
    let pictrs_alias: String
    let pictrs_delete_token: String
    let published: Date
}
