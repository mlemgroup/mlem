//
//  Handle.swift
//  Mlem
//
//  Created by Sjmarf on 2026-06-23.
//

public protocol Handle {
    init(username: String, host: String)

    func description(withPrefix: Bool) -> String
}
