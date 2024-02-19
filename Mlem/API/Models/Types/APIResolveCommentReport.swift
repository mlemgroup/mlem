//
//  APIResolveCommentReport.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/ResolveCommentReport.ts
struct APIResolveCommentReport: Codable {
    let report_id: Int
    let resolved: Bool

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "report_id", value: String(report_id)),
            .init(name: "resolved", value: String(resolved))
        ]
    }
}
