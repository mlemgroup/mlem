//
//  Interactable2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/08/2024.
//

import MlemMiddleware

extension ShimFlairContextProviding {
    func contextualFlairs() -> Set<PersonFlair> {
        var output: Set<PersonFlair> = []
        if creatorIsAdmin.value ?? false {
            output.insert(.admin)
        }
        if creatorIsModerator.value ?? false {
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
