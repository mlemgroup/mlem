//
//  APIApproveRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/ApproveRegistrationApplication.ts
struct APIApproveRegistrationApplication: Codable {
    let id: Int
    let approve: Bool
    let deny_reason: String?
}
