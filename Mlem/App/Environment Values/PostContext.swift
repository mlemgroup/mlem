//
//  PostContext.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-22.
//

import MlemMiddleware
import SwiftUI

struct PostContext: EnvironmentKey {
    static let defaultValue: (any Post1Providing)? = nil
}

extension EnvironmentValues {
    var postContext: (any Post1Providing)? {
        get { self[PostContext.self] }
        set { self[PostContext.self] = newValue }
    }
}
