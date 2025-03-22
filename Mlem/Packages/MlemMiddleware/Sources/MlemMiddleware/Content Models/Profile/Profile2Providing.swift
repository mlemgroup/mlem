//
//  ProfileProviding.swift
//
//
//  Created by Sjmarf on 08/05/2024.
//

import Foundation

public protocol Profile2Providing: Profile1Providing {
    var displayName: String { get }
    var description: String? { get }
    var banner: URL? { get }
    var created: Date { get }
    var updated: Date? { get }
}
