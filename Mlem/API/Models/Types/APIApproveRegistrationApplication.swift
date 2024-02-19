//
//  APIApproveRegistrationApplication.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ApproveRegistrationApplication.ts
struct APIApproveRegistrationApplication: Codable {
    let id: Int
    let approve: Bool
    let deny_reason: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "id", value: String(id)),
            .init(name: "approve", value: String(approve)),
            .init(name: "deny_reason", value: deny_reason)
        ]
    }
}
