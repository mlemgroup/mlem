//
//  Person1Providing+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-29.
//

import Foundation
import MlemMiddleware

extension Person1Providing {
    func getFlairs(
        postContext: (any Post)? = nil,
        communityContext: (any Community)? = nil
    ) -> [PersonFlair] {
        var flairs: [PersonFlair] = isMlemDeveloper ? [.developer] : []
        if isBot {
            flairs.append(.bot)
        }
        if instanceBan != .notBanned {
            flairs.append(.banned)
        }
        return flairs
    }
}
