//
//  APIChangePassword.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ChangePassword.ts
struct APIChangePassword: Codable {
    let new_password: String
    let new_password_verify: String
    let old_password: String
}
