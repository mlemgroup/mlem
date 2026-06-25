//
//  LemmyPagedResponse.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-12-05.
//  

import Foundation

public struct LemmyPagedResponse<Value: Codable>: Codable {
    public let items: [Value]
    public let nextPage: String?
    public let prevPage: String?

    enum CodingKeys: String, CodingKey {
        case items = "items"
        case nextPage = "next_page"
        case prevPage = "prev_page"
    }
}
