//
//  ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

struct ModlogEntry: Hashable, Equatable {
    let date: Date
    let description: String
    let contextLinks: [LinkType]
    
    init(from apiType: APIModRemovePostView) {
        self.date = apiType.modRemovePost.when_
        
        let agent = apiType.moderator?.name ?? "Moderator"
        self.description = "\(agent) removed post \"\(apiType.post.name)\" from \(apiType.community.name)"
        
        var contextLinks: [LinkType] = .init()
        if let moderator = apiType.moderator {
            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
        }
        contextLinks.append(.postFromApiType(1, apiType.post))
        contextLinks.append(.communityFromApiType(2, apiType.community))
        self.contextLinks = contextLinks
    }
    
    static func == (lhs: ModlogEntry, rhs: ModlogEntry) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(description)
    }
}
