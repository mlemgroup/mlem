//
//  APILoginResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// LoginResponse.ts
struct APILoginResponse: Codable {
    let jwt: String?
    let registrationCreated: Bool
    let verifyEmailSent: Bool
}
