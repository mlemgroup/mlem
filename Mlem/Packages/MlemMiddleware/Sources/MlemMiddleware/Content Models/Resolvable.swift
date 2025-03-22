//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-26.
//

import Foundation

public protocol Resolvable {
    /// An array of available URLs for this entity that can be resolved by another `ApiClient`.
    var allResolvableUrls: [URL] { get }
}
