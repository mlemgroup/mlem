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
        if creatorIsAdmin {
            output.insert(.admin)
        }
        if creatorIsModerator {
            output.insert(.moderator)
        }
        if let comment = self as? any Comment2Providing {
            if let post = comment.post_, comment.creatorId == post.creatorId {
                output.insert(.op)
            }
        }
        return output
    }
}
