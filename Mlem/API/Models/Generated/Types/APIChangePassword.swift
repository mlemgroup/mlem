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
    let newPassword: String
    let newPasswordVerify: String
    let oldPassword: String
}
