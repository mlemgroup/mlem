//
//  Interactable2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/08/2024.
//

import MlemMiddleware

extension Interactable2Providing {
    func contextualFlairs() -> Set<PersonFlair> {
        var output: Set<PersonFlair> = []
        if creatorIsAdmin ?? api.myInstance?.administrators.contains(where: { $0.id == id }) ?? false {
            output.insert(.admin)
        }
        if creatorIsModerator ?? false {
            output.insert(.moderator)
        }
        if bannedFromCommunity ?? false {
            output.insert(.bannedFromCommunity)
        }
        if let comment = self as? any Comment2Providing {
            if let post = comment.post_, comment.creatorId == post.creatorId {
                output.insert(.op)
            }
        }
        return output
    }
}
