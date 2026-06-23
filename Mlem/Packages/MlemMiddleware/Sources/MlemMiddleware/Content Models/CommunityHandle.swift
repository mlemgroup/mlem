//
//  CommunityHandle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

import Foundation

public struct CommunityHandle: Handle {
    public static let prefix: String = "!"

    public let username: String
    public let host: String

    public init(username: String, host: String) {
        self.username = username
        self.host = host
    }
}
