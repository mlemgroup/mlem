//
//  Person+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Person1: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(with person: ApiPerson) {
        updatedDate = person.updated
        displayName = person.displayName
        description = person.bio
        avatar = person.avatar
        banner = person.banner
        
        deleted = person.deleted
        isBot = person.botAccount
        
        if person.banned {
            if let expires = person.banExpires {
                instanceBan = .temporarilyBanned(expires: expires)
            } else {
                instanceBan = .permanentlyBanned
            }
        } else {
            instanceBan = .notBanned
        }
    }
}

extension Person2: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(with apiType: any Person2ApiBacker) {
        postCount = apiType.counts.postCount
        commentCount = apiType.counts.commentCount
        person1.update(with: apiType.person)
    }
}

extension Person3: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(moderatedCommunities: [Community1], person2ApiBacker: any Person2ApiBacker) {
        self.moderatedCommunities = moderatedCommunities
        person2.update(with: person2ApiBacker)
    }
}
