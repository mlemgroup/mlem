//
//  Profile1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware

extension Profile1Providing {
    static var avatarType: AvatarType {
        if self is any Community.Type {
            return .community
        } else if self is any Instance.Type {
            return .instance
        } else if self is any Person.Type || self is any AccountProviding.Type {
            return .person
        } else {
            assertionFailure()
            return .person
        }
    }
}
