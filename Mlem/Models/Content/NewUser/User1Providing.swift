//
//  User1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol User1Providing: Identifiable {
    var source: any APISource { get }
    
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
    
    var blocked: Bool { get }
    
    // From User2Providing. These are defined as nil in the extension below
    var postCount: Int? { get }
    var postScore: Int? { get }
    var commentCount: Int? { get }
    var commentScore: Int? { get }
    
    // From User3Providing. These are defined as nil in the extension below
    var instance: Instance1? { get }
    var moderatedCommunities: [Community1]? { get }
}

typealias User = User1Providing

extension User1Providing {
    var actorId: URL { user1.actorId }
    var id: Int { user1.id }
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
    var blocked: Bool { user1.blocked }
    
    var postCount: Int? { nil }
    var postScore: Int? { nil }
    var commentCount: Int? { nil }
    var commentScore: Int? { nil }
    
    var instance: Instance1? { nil }
    var moderatedCommunities: [Community1]? { nil }
}
