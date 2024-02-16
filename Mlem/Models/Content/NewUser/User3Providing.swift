//
//  User3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol User3Providing: User2Providing {
    var user3: User3 { get }
    
    var instance: Instance1! { get }
    var moderatedCommunities: [Community1] { get }
}

extension User3Providing {
    var user2: User2 { user3.user2 }
    
    var instance: Instance1! { user3.instance }
    var moderatedCommunities: [Community1] { user3.moderatedCommunities }
}
