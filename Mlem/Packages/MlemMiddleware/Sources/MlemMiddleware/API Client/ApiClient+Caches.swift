//
//  ApiClient+Caches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public struct WeakReference<Content: AnyObject> {
    public weak var content: Content?
    
    public init(content: Content) {
        self.content = content
    }
}

public protocol CacheIdentifiable {
    var cacheId: Int { get }
}

extension ApiClient {
    struct BaseCacheGroup {
        var instance1: Instance1Cache = .init()
        var instance2: Instance2Cache = .init()
        var instance3: Instance3Cache = .init()
        
        var community1: Community1Cache = .init()
        var community2: Community2Cache = .init()
        var community3: Community3Cache = .init()
        
        var person1: Person1Cache = .init()
        var person2: Person2Cache = .init()
        var person3: Person3Cache = .init()
        var person4: Person4Cache = .init()
        
        var post1: Post1Cache = .init()
        var post2: Post2Cache = .init()
        var post3: Post3Cache = .init()
        
        var comment1: Comment1Cache = .init()
        var comment2: Comment2Cache = .init()
        
        var reply1: Reply1Cache = .init()
        var reply2: Reply2Cache = .init()
        
        var message1: Message1Cache = .init()
        var message2: Message2Cache = .init()
        
        var imageUpload1: ImageUpload1Cache = .init()
        
        var report: ReportCache = .init()
        
        var personVote: PersonVoteCache = .init()
        
        var registrationApplication: RegistrationApplicationCache = .init()
        
        func clean() {
            community1.clean()
            community2.clean()
            community3.clean()
            person1.clean()
            person2.clean()
            person3.clean()
            person4.clean()
            post1.clean()
            post2.clean()
            post3.clean()
            comment1.clean()
            comment2.clean()
            reply1.clean()
            reply2.clean()
            message1.clean()
            message2.clean()
            imageUpload1.clean()
            report.clean()
            personVote.clean()
            registrationApplication.clean()
        }
    }
}
