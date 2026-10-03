//
//  LemmyV4ImageUploadResponse.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-03.
//

import Foundation

struct LemmyV4ImageUploadResponse: Codable {
    let imageUrl: URL
    let filename: String
}
