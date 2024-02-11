//
//  User1.swift
//  Mlem
//
//  Created by Sjmarf on 11/02/2024.
//

import Foundation
import SwiftUI

protocol User1Providing {
    var id: Int { get }
    var ban: BanType? { get }
    var isAdmin: Bool { get }
    
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

enum BanType {
    case permanent
    case temporary(Date)
}

@Observable
class User1: User1Providing, BaseModel {
    // Conformance
    typealias APIType = APIPerson
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    let core1: UserCore1
    
    let id: Int
    var ban: BanType? = nil
    
    // This used to be provided in APIPersonView pre-0.19, but isn't anymore. Now, this is set from outside User1 once APISiteView is fetched
    var isAdmin: Bool = false
    
    // Forwarded properties from UserCore1
    var actorId: URL { core1.actorId }
    var name: String { core1.name }
    var creationDate: Date { core1.creationDate }
    var updatedDate: Date? { core1.updatedDate }
    var displayName: String? { core1.displayName }
    var description: String? { core1.description }
    var matrixId: String? { core1.matrixId }
    var avatar: URL? { core1.avatar }
    var banner: URL? { core1.banner }
    var deleted: Bool { core1.deleted }
    var isBot: Bool { core1.isBot }
    
    required init(sourceInstance: NewInstanceStub, from person: APIPerson) {
        self.sourceInstance = sourceInstance
        self.core1 = UserCore1.create(from: person)
        
        self.id = person.id
        self.update(with: person, cascade: false)
    }
    
    func update(with person: APIPerson, cascade: Bool = true) {
        if person.banned {
            if let expiration = person.banExpires {
                self.ban = .temporary(expiration)
            } else {
                self.ban = .permanent
            }
        } else {
            self.ban = nil
        }
        if cascade {
            self.core1.update(with: person)
        }
    }
}
