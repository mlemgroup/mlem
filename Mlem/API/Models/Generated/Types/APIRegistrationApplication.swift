//
//  APIRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/RegistrationApplication.ts
struct APIRegistrationApplication: Codable {
    // swiftlint:disable:next identifier_name
    let id: Int
    let localUserId: Int
    let answer: String
    let adminId: Int?
    let denyReason: String?
    let published: Date
}
