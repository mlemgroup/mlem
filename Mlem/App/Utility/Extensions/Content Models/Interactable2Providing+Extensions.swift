//
//  Interactable2Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 05/08/2024.
//

import MlemMiddleware

// TODO: NOW collapse into Interactable

extension ShimInteractable2Providing {
    func contextualFlairs() -> Set<PersonFlair> {
        var output: Set<PersonFlair> = []
        if creatorIsAdmin.value ?? false {
            output.insert(.admin)
        }
        if creatorIsModerator.value ?? false {
            output.insert(.moderator)
        }
        if let comment = self as? Comment {
            if let post = comment.post.value_, comment.creatorId == post.creatorId {
                output.insert(.op)
            }
        }
        return output
    }
}
