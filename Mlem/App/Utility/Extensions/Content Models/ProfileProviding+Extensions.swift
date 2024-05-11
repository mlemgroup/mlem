//
//  ProfileProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware

extension ProfileProviding {
    static var avatarType: AvatarType {
        if self is any Community.Type {
            return .community
        } else if self is any Instance.Type {
            return .instance
        } else if self is any Person.Type {
            return .person
        } else {
            assertionFailure()
            return .person
        }
    }
}
