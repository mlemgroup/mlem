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
    var actorID: URL { get }
    var local: Bool { get }
    
    var updatedDate: Date? { get }
    
    var displayName: String? { get }
    var description: String? { get }
    var matrixId: String? { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    
    var deleted: Bool { get }
    var banned: Bool { get }
    var isBot: Bool { get }
}

@Observable
final class UserTier1: UserTier1Providing, DependentContentModel {
    typealias APIType = APIPerson
    var source: any APISource
    
    let id: Int
    let name: String
    let creationDate: Date
    let actorID: URL
    let local: Bool
    
    private(set) var updatedDate: Date?
    private(set) var displayName: String?
    private(set) var description: String?
    private(set) var matrixId: String?
    private(set) var avatar: URL?
    private(set) var banner: URL?
    
    private(set) var deleted: Bool
    private(set) var banned: Bool
    private(set) var isBot: Bool
    
    init(source: any APISource, from person: APIPerson) {
        self.source = source

        self.id = person.id
        self.name = person.name
        self.creationDate = person.published
        self.actorID = person.actorId
        self.local = person.local
        
        self.updatedDate = person.updated
        
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.banned = person.banned
        self.isBot = person.botAccount
    }
    
    func update(with person: APIPerson) {
        self.updatedDate = person.updated
        
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.banned = person.banned
        self.isBot = person.botAccount
    }
}
