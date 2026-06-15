//
//  Message2Providing.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public protocol Message2Providing: Message1Providing, ActorIdentifiable {
    var message2: Message2 { get }
    
    var creator: Person { get }
    var recipient: Person { get }
}

public extension Message2Providing {
    var message1: Message1 { message2.message1 }
    
    var creator: Person { message2.creator }
    var recipient: Person { message2.recipient }
    
    var creator_: Person? { message2.creator }
    var recipient_: Person? { message2.recipient }
}
