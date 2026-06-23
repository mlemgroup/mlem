//
//  Handle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

public protocol Handle {
    static var prefix: String { get }

    var username: String { get }
    var host: String { get }

    init(username: String, host: String)

    func description(withPrefix: Bool) -> String
}

public extension Handle {
    func description(withPrefix: Bool) -> String {
        if withPrefix {
            "\(Self.prefix)\(username)@\(host)"
        } else {
            "\(username)@\(host)"
        }
    }
}
