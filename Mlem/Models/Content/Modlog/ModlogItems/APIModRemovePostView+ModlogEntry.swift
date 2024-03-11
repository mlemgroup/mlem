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
    
    var context: [ModlogContext] {
        var ret: [ModlogContext] = .init()
        if let moderator {
            ret.append(.user(moderator))
        }
        ret.append(.post(post))
        ret.append(.community(community))
        return ret
    }
}
