//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class UserCore1: CoreModel {
    static var cache: CoreContentCache<UserCore1> = .init()
    typealias APIType = APIPerson

    let actorId: URL
    
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
    
    init(from person: APIPerson) {
        self.actorId = person.actorId
        self.name = person.name
        self.creationDate = person.published
        self.update(with: person)
    }
    
    func update(with person: APIPerson, cascade: Bool = true) {
        self.updatedDate = person.updated
        self.displayName = person.displayName
        self.description = person.bio
        self.avatar = person.avatarUrl
        self.banner = person.bannerUrl
        
        self.deleted = person.deleted
        self.isBot = person.botAccount
    }
}
