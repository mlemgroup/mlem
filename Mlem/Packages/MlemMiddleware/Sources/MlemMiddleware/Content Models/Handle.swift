//
//  Handle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

import Foundation

public protocol Handle: Hashable {
    static var prefix: Character { get }

    var username: String { get }
    var host: String { get }

    init(username: String, host: String) throws (HandleError)

    func description(withPrefix: Bool) -> String
}

public extension Handle {
    init(string: String) throws(HandleError) {
        guard string.first == Self.prefix else { throw .invalidFormat }
        let parts = string.dropFirst().split(separator: "@", maxSplits: 1)
        try self.init(
            username: String(parts[0]),
            host: String(parts[1])
        )
    }

    func baseUrl() -> URL {
        // Guaranteed to succeed because we validated the host at init time
        URL(string: "https://\(host)")!
    }

    func description(withPrefix: Bool) -> String {
        if withPrefix {
            "\(Self.prefix)\(username)@\(host)"
        } else {
            "\(username)@\(host)"
        }
    }
}

public enum HandleError: Error {
    case invalidFormat, invalidHost
} 
