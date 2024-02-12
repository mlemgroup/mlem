//
//  User1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol User1Providing: ActorIdentifiable {
    var user1: User1 { get }
    
    var name: String { get }
    var creationDate: Date { get }
    var updatedDate: Date? { get }
    var displayName: String? { get }
    var description: String? { get }
    var matrixId: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var deleted: Bool { get }
    var isBot: Bool { get }
}

typealias User = User1Providing

extension User1Providing {
    var actorId: URL { user1.actorId }
    var name: String { user1.name }
    var creationDate: Date { user1.creationDate }
    var updatedDate: Date? { user1.updatedDate }
    var displayName: String? { user1.displayName }
    var description: String? { user1.description }
    var matrixId: String? { user1.matrixId }
    var avatar: URL? { user1.avatar }
    var banner: URL? { user1.banner }
    var deleted: Bool { user1.deleted }
    var isBot: Bool { user1.isBot }
}
