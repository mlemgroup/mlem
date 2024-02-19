//
//  APIPasswordChangeAfterReset.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/PasswordChangeAfterReset.ts
struct APIPasswordChangeAfterReset: Codable {
    let token: String
    let password: String
    let passwordVerify: String
}
