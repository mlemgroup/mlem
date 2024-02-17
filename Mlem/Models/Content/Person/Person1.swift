//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person1: Person1Providing, NewContentModel {
    typealias APIType = APIPerson
    var person1: Person1 { self }
    
    var source: any APISource
    
    let actorId: URL
    let id: Int
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date? = .distantPast
    var displayName: String? = nil
    var description: String? = nil
    var matrixId: String? = nil
    var avatar: URL? = nil
    var banner: URL? = nil
    
    var deleted: Bool = false
    var isBot: Bool = false
    
    var instanceBan: InstanceBanType = .notBanned
    
    // These aren't included in the APIPerson, and so are set externally by Post2 instead
    var blocked: Bool = false
    
    init(source: any APISource, from person: APIPerson) {
        self.source = source
        self.actorId = person.actorId
        self.id = person.id
        self.name = person.name
        self.creationDate = person.published
        
        self.update(with: person)
    }
    
    func update(with person: APIPerson) {
        self.updatedDate = person.updated
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.isBot = person.botAccount
        
        if person.banned {
            if let expires = person.banExpires {
                instanceBan = .temporarilyBanned(expires: expires)
            } else {
                instanceBan = .permanentlyBanned
            }
        } else {
            instanceBan = .notBanned
        }
    }
}
