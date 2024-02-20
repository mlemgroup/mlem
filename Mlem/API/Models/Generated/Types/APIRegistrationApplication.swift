//
//  APIRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// RegistrationApplication.ts
struct APIRegistrationApplication: Codable {
    let id: Int
    let localUserId: Int
    let answer: String
    let adminId: Int?
    let denyReason: String?
    let published: Date
}
