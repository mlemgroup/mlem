//
//  UserTier1.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person1: Person1Providing {
    var api: ApiClient
    var person1: Person1 { self }
    
    let actorId: URL
    let id: Int
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date? = .distantPast
    var displayName: String?
    var description: String?
    var matrixId: String?
    var avatar: URL?
    var banner: URL?
    
    var deleted: Bool = false
    var isBot: Bool = false
    
    var instanceBan: InstanceBanType = .notBanned
    
    // These aren't included in the ApiPerson, and so are set externally by Post2 instead
    var blocked: Bool = false
    
    init(
        api: ApiClient,
        actorId: URL,
        id: Int,
        name: String,
        creationDate: Date,
        updatedDate: Date? = .distantPast,
        displayName: String? = nil,
        description: String? = nil,
        matrixId: String? = nil,
        avatar: URL? = nil,
        banner: URL? = nil,
        deleted: Bool = false,
        isBot: Bool = false,
        instanceBan: InstanceBanType = .notBanned,
        blocked: Bool = false
    ) {
        self.api = api
        self.actorId = actorId
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.updatedDate = updatedDate
        self.displayName = displayName
        self.description = description
        self.matrixId = matrixId
        self.avatar = avatar
        self.banner = banner
        self.deleted = deleted
        self.isBot = isBot
        self.instanceBan = instanceBan
        self.blocked = blocked
    }
}
