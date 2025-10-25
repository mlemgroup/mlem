//
//  CanModerateProviding.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-15.
//

import Foundation

public protocol CanModerateProviding: ContentIdentifiable {
    var canModerate: Bool { get }
}
