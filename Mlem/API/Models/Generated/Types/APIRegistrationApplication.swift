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
    let id: Int
    let local_user_id: Int
    let answer: String
    let admin_id: Int?
    let deny_reason: String?
    let published: Date
}
