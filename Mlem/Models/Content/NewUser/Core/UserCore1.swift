//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

protocol UserTier1Providing {
    var id: Int { get }
    
    var name: String { get }
    var creationDate: Date { get }
    var local: Bool { get }
    
    var updatedDate: Date? { get }
    
    var displayName: String? { get }
    var description: String? { get }
    var matrixId: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    
    var deleted: Bool { get }
    var isBot: Bool { get }
}

@Observable
final class UserCore1: CoreModel {
    static var cache: CoreContentCache<UserCore1> = .init()
    typealias APIType = APIPerson

    let actorId: URL
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date?
    var displayName: String?
    var description: String?
    var matrixId: String?
    var avatar: URL?
    var banner: URL?
    
    var deleted: Bool
    var isBot: Bool
    
    init(from person: APIPerson) {
        self.actorId = person.actorId
        
        self.name = person.name
        self.creationDate = person.published

        self.updatedDate = person.updated
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.isBot = person.botAccount
    }
    
    func update(with person: APIPerson) {
        self.updatedDate = person.updated
        
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.isBot = person.botAccount
    }
}
