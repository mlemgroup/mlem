//
//  ProfileProviding.swift
//
//
//  Created by Sjmarf on 20/05/2024.
//

import Foundation

public protocol ProfileProviding: ActorIdentifiable {
    var name: String { get }
    var avatar: URL? { get }
    var blocked: any RealizedValueProviding<Bool> { get }
    
    var displayName: String { get }
    var description: String? { get }
    var banner: URL? { get }
    var profileCreated: Date? { get }
    var updated: Date? { get }
}
