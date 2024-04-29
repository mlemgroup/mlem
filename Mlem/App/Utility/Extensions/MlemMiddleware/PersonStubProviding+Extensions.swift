//
//  PersonStubProviding+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-29.
//

import Foundation
import MlemMiddleware

extension PersonStubProviding {
    func getFlairs(
        postContext: (any Post)? = nil,
        communityContext: (any Community)? = nil
    ) -> [PersonFlair] { isMlemDeveloper ? [.developer] : [] }
}
