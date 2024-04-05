//
//  APIRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27
//

import Foundation

// RegistrationApplication.ts
struct APIRegistrationApplication: Decodable, Hashable {
    let id: Int
    let localUserId: Int
    let answer: String
    let adminId: Int?
    let denyReason: String?
    let published: Date
}
