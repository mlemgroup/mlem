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
        
        var community: CommunityCache = .init()
        var person: PersonCache = .init()
        var post: PostCache = .init()
        var comment: CommentCache = .init()
        
        var message1: Message1Cache = .init()
        var message2: Message2Cache = .init()
        
        var imageUpload1: ImageUpload1Cache = .init()
        
        var report: ReportCache = .init()
        
        var personVote: PersonVoteCache = .init()
        
        var registrationApplication: RegistrationApplicationCache = .init()

        var notification: NotificationCache = .init()
        
        func clean() {
            community1.clean()
            community2.clean()
            community3.clean()
            person.clean()
            post.clean()
            comment.clean()
            message1.clean()
            message2.clean()
            imageUpload1.clean()
            report.clean()
            personVote.clean()
            registrationApplication.clean()
            notification.clean()
        }
    }
}
