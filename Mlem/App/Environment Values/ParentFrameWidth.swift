//
//  ParentFrameWidth.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-28.
//

import MlemMiddleware
import SwiftUI

struct ParentFrameWidth: EnvironmentKey {
    static let defaultValue: CGFloat = .zero
}

extension EnvironmentValues {
    var parentFrameWidth: CGFloat {
        get { self[ParentFrameWidth.self] }
        set { self[ParentFrameWidth.self] = newValue }
    }
}
