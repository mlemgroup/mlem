//
//  APILoginResponse.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/LoginResponse.ts
struct APILoginResponse: Codable {
    let jwt: String?
    let registrationCreated: Bool
    let verifyEmailSent: Bool
}
