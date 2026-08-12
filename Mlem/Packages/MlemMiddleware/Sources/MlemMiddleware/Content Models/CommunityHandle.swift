//
//  CommunityHandle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

import Foundation

public struct CommunityHandle: Handle {
    public static let prefix: Character = "!"

    public let username: String
    public let host: String

    public init(username: String, host: String) throws(HandleError) {
        self.username = username
        self.host = host
        guard URL(string: "https://\(host)") != nil else {
            throw .invalidHost
        }
    }
}
