//
//  ApiLoginResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// LoginResponse.ts
struct ApiLoginResponse: Codable {
    let jwt: String?
    let registrationCreated: Bool
    let verifyEmailSent: Bool
}
