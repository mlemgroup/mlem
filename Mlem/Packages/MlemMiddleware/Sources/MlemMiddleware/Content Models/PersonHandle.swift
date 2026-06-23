//
//  PersonHandle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

import Foundation

public struct PersonHandle {
    public let username: String
    public let host: String

    public init(username: String, host: String) {
        self.username = username
        self.host = host
    }

    public func description(withPrefix: Bool) -> String {
        if withPrefix {
            "@\(username)@\(host)"
        } else {
            "\(username)@\(host)"
        }
    }
}
