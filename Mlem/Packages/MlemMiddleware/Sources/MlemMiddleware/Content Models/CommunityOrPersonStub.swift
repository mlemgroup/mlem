//
//  CommunityOrAccount.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation
import Observation

public protocol CommunityOrPerson: ContentModel, ActorIdentifiable {
    static var identifierPrefix: String { get }
    
    var name: String { get }
}

public extension CommunityOrPerson {
    var fullName: String { "\(name)@\(host)" }
    
    var fullNameWithPrefix: String { "\(Self.identifierPrefix)\(name)@\(host)" }
}
