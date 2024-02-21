//
//  User3Providing.swift
//  Mlem
//
//  Created by Sjmarf on 12/02/2024.
//

import Foundation

protocol Person3Providing: Person2Providing {
    var person3: Person3 { get }
    
    var instance: Instance1! { get }
    var moderatedCommunities: [Community1] { get }
}

extension Person3Providing {
    var person2: Person2 { person3.person2 }
    
    var instance: Instance1! { person3.instance }
    var moderatedCommunities: [Community1] { person3.moderatedCommunities }
    
    var instance_: Instance1? { person3.instance }
    var moderatedCommunities_: [Community1]? { person3.moderatedCommunities }
}
