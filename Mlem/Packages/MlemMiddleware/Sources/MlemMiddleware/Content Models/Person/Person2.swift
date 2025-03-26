//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Observation

@Observable
public final class Person2: Person2Providing {
    public static let tierNumber: Int = 2
    public var api: ApiClient
    public var person2: Person2 { self }
    
    public let person1: Person1
    
    public var postCount: Int
    public var commentCount: Int
    
    public var isAdmin: Bool
    
    init(
        api: ApiClient,
        person1: Person1,
        postCount: Int,
        commentCount: Int,
        isAdmin: Bool
    ) {
        self.api = api
        self.person1 = person1
        self.postCount = postCount
        self.commentCount = commentCount
        self.isAdmin = isAdmin
    }
}
