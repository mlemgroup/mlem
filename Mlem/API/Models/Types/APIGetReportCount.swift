//
//  APIGetReportCount.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetReportCount.ts
struct APIGetReportCount: Codable {
    let community_id: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "community_id", value: community_id.map(String.init))
        ]
    }
}
