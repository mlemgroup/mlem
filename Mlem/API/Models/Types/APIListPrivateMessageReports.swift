//
//  APIListPrivateMessageReports.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ListPrivateMessageReports.ts
struct APIListPrivateMessageReports: Codable {
    let page: Int?
    let limit: Int?
    let unresolved_only: Bool?

    func toQueryItems() -> [URLQueryItem] {
        return [
            .init(name: "page", value: page.map(String.init)),
            .init(name: "limit", value: limit.map(String.init)),
            .init(name: "unresolved_only", value: unresolved_only.map(String.init))
        ]
    }

}
