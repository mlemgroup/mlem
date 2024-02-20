//
//  APIChangePassword.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ChangePassword.ts
struct APIChangePassword: Codable {
    let newPassword: String
    let newPasswordVerify: String
    let oldPassword: String
}
