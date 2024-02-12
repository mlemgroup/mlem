//
//  User2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol User2Providing: User1Providing {
    var user2: User2 { get }
    
    var postCount: Int { get }
    var postScore: Int { get }
    var commentCount: Int { get }
    var commentScore: Int { get }
}

extension User2Providing {
    var postCount: Int { user2.postCount }
    var postScore: Int { user2.postScore }
    var commentCount: Int { user2.commentCount }
    var commentScore: Int { user2.commentScore }
}
