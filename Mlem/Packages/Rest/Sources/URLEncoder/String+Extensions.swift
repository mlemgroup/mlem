//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal extension String {
    func camelToSnakeCase() -> String {
        replacing(/([a-z])([A-Z])/) { "\($0.output.1)_\($0.output.2)"
        }.lowercased()
    }
}
