//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Observation

@Observable
public final class Person3: Person3Providing {
    public static let tierNumber: Int = 3
    public var api: ApiClient
    public var person3: Person3 { self }

    public let person2: Person2

    public var instance: Instance1?
    public var moderatedCommunities: [Community1] = .init()
    
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
    
    public func upgrade() async throws -> any Person { self }
}
