//
//  APIGetSiteMetadata.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/GetSiteMetadata.ts
struct APIGetSiteMetadata: Codable {
    let url: String

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "url", value: url)
        ]
    }
}
