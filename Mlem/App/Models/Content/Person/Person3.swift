//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person3: Person3Providing {
    var api: ApiClient
    var person3: Person3 { self }

    let person2: Person2

    var instance: Instance1!
    var moderatedCommunities: [Community1] = .init()
    
    init(
        api: ApiClient,
        person2: Person2,
        instance: Instance1? = nil,
        moderatedCommunities: [Community1] = .init()
    ) {
        self.api = api
        self.person2 = person2
        self.instance = instance
        self.moderatedCommunities = moderatedCommunities
    }
}
