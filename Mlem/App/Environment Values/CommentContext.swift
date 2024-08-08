//
//  CommentContext.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-05-22.
//

import MlemMiddleware
import SwiftUI

struct CommentContext: EnvironmentKey {
    static let defaultValue: (any Comment1Providing)? = nil
}

extension EnvironmentValues {
    var commentContext: (any Comment1Providing)? {
        get { self[CommentContext.self] }
        set { self[CommentContext.self] = newValue }
    }
}
