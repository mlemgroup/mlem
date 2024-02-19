//
//  APILoginResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/LoginResponse.ts
struct APILoginResponse: Codable {
    let jwt: String?
    let registration_created: Bool
    let verify_email_sent: Bool
}
