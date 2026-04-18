//
//  ProfileProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-13.
//

import Foundation
import MlemMiddleware

extension ProfileProviding {
    var isCakeDay: Bool { profileCreated?.isAnniversaryToday ?? false }
    
    var createdRecently: Bool {
        guard let created = profileCreated else { return false }
        let intervalSinceCreation = Date.now.timeIntervalSince(created)
        return intervalSinceCreation < 30 * 24 * 60 * 60
    }
    
    static var avatarFallback: MediaView.Fallback {
        if self is Community.Type {
            return .communityAvatar
        } else if self is Instance.Type {
            return .instanceAvatar
        } else if self is Person.Type || self is any Account.Type {
            return .personAvatar
        } else {
            assertionFailure()
            return .personAvatar
        }
    }
}
