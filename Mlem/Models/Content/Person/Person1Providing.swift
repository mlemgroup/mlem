//
//  User1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Person1Providing: PersonStubProviding, Identifiable {
    var source: any APISource { get }
    
    var person1: Person1 { get }
    
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
    var instanceBan: InstanceBanType { get }
    
    var blocked: Bool { get }
}

typealias Person = Person1Providing

extension Person1Providing {  
    var actorId: URL { person1.actorId }
    var id: Int { person1.id }
    var name: String { person1.name }
    var creationDate: Date { person1.creationDate }
    var updatedDate: Date? { person1.updatedDate }
    var displayName: String? { person1.displayName }
    var description: String? { person1.description }
    var matrixId: String? { person1.matrixId }
    var avatar: URL? { person1.avatar }
    var banner: URL? { person1.banner }
    var deleted: Bool { person1.deleted }
    var isBot: Bool { person1.isBot }
    var instanceBan: InstanceBanType { person1.instanceBan }
    var blocked: Bool { person1.blocked }
}
