//
//  User2Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Person2Providing: Person1Providing {
    var person2: Person2 { get }
    
    var postCount: Int { get }
    var postScore: Int { get }
    var commentCount: Int { get }
    var commentScore: Int { get }
}

extension Person2Providing {
    var person1: Person1 { person2.person1 }
    
    var postCount: Int { person2.postCount }
    var postScore: Int { person2.postScore }
    var commentCount: Int { person2.commentCount }
    var commentScore: Int { person2.commentScore }
    
    var postCount_: Int? { person2.postCount }
    var postScore_: Int? { person2.postScore }
    var commentCount_: Int? { person2.commentCount }
    var commentScore_: Int? { person2.commentScore }
}
