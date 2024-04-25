//
//  ApiClient+Caches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

struct WeakReference<Content: AnyObject> {
    weak var content: Content?
}

protocol CacheIdentifiable {
    var cacheId: Int { get }
}

extension ApiClient {
    struct BaseCacheGroup {
        var instance1: Instance1Cache
        var instance2: Instance2Cache
        var instance3: Instance3Cache
        
        var community1: Community1Cache
        var community2: Community2Cache
        var community3: Community3Cache
        
        var person1: Person1Cache
        var person2: Person2Cache
        var person3: Person3Cache
        
        var post1: Post1Cache
        var post2: Post2Cache
        
        // We can only create a User for the logged-in account at the moment, so we only need one
        weak var user: User?
        
        init() {
            self.instance1 = .init()
            self.person1 = .init()
            self.community1 = .init()
            self.post1 = .init()
            
            self.instance2 = .init(instance1Cache: instance1)
            self.person2 = .init(person1Cache: person1)
            self.community2 = .init(community1Cache: community1)
            self.post2 = .init(post1Cache: post1, person1Cache: person1, community1Cache: community1)
            
            self.instance3 = .init(instance2Cache: instance2)
            self.person3 = .init(person2Cache: person2, community1Cache: community1, instance1Cache: instance1)
            self.community3 = .init(community2Cache: community2, instance1Cache: instance1, person1Cache: person1)
        }
        
        func clean() {
            community1.clean()
            community2.clean()
            community3.clean()
            person1.clean()
            person2.clean()
            person3.clean()
            post1.clean()
            post2.clean()
        }
    }
}
