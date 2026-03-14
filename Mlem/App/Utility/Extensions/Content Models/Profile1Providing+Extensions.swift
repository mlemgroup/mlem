//
//  Profile1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware

extension Profile1Providing {
    static var avatarFallback: MediaView.Fallback {
        if self is Community.Type {
            return .communityAvatar
        } else if self is any DeprecatedInstance.Type {
            return .instanceAvatar
        } else if self is Person.Type || self is any Account.Type {
            return .personAvatar
        } else {
            assertionFailure()
            return .personAvatar
        }
    }
}
