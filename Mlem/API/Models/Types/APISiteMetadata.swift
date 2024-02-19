//
//  APISiteMetadata.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/SiteMetadata.ts
struct APISiteMetadata: Codable {
    let title: String?
    let description: String?
    let image: String?
    let embed_video_url: String?

    func toQueryItems() -> [URLQueryItem] {
        [
            .init(name: "title", value: title),
            .init(name: "description", value: description),
            .init(name: "image", value: image),
            .init(name: "embed_video_url", value: embed_video_url)
        ]
    }
}
