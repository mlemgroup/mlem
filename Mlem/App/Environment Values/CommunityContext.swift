//
//  CommunityContext.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-22.
//

import MlemMiddleware
import SwiftUI

struct CommunityContext: EnvironmentKey {
    static let defaultValue: (any Community3Providing)? = nil
}

extension EnvironmentValues {
    var communityContext: (any Community3Providing)? {
        get { self[CommunityContext.self] }
        set { self[CommunityContext.self] = newValue }
    }
}
