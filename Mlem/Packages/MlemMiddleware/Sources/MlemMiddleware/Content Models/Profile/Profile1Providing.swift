//
//  Profile1Providing.swift
//
//
//  Created by Sjmarf on 20/05/2024.
//

import Foundation

public protocol Profile1Providing: ActorIdentifiable {
    var name: String { get }
    var avatar: URL? { get }
    var blocked: Bool { get }
    
    var displayName_: String? { get }
    var description_: String? { get }
    var banner_: URL? { get }
    var created_: Date? { get }
    var updated_: Date? { get }
}

public extension Profile1Providing {
    var displayName_: String? { nil }
    var description_: String? { nil }
    var banner_: URL? { nil }
    var created_: Date? { nil }
    var updated_: Date? { nil }
}
