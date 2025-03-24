//
//  Message2Providing.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public protocol Message2Providing: Message1Providing, ActorIdentifiable {
    var message2: Message2 { get }
    
    var creator: Person1 { get }
    var recipient: Person1 { get }
}

public extension Message2Providing {
    var message1: Message1 { message2.message1 }
    
    var creator: Person1 { message2.creator }
    var recipient: Person1 { message2.recipient }
    
    var creator_: Person1? { message2.creator }
    var recipient_: Person1? { message2.recipient }
}
