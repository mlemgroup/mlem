//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class User1: User1Providing, NewContentModel {
    typealias APIType = APIPerson
    var user1: User1 { self }
    
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
    
    // This isn't included in the APIPerson (or any higher-tier API types)
    var blocked: Bool = false
    
    var deleted: Bool = false
    var isBot: Bool = false
    
    init(source: any APISource, from person: APIPerson) {
        self.source = source
        self.actorId = person.actorId
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
    }
}
