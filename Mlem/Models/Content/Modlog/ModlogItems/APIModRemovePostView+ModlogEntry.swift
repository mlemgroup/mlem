//
//  APIModRemovePostView+ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation

extension APIModRemovePostView: ModlogEntry {
    var date: Date { modRemovePost.when_ }
    
    var description: String {
        let agent = moderator?.name ?? "Moderator"
        return "\(agent) removed post \"\(post.name)\" from \(community.name)"
    }
    
    var contextLinks: [LinkType] {
        var ret: [LinkType] = .init()
        
        if let moderator {
            ret.append(.userFromModel(0, UserModel(from: moderator)))
        }
        ret.append(.postFromApiType(1, post))
        ret.append(.communityFromApiType(2, community))
        
        return ret
    }
}
