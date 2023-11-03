//
//  FancyTabBarDoubleTapEnvironmentKey.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-02.
//

import Foundation
import SwiftUI

struct FancyTabBarDoubleTapEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int? { nil }
}

extension EnvironmentValues {
    var tabReselectionHashValue: Int? {
        get { self[FancyTabBarDoubleTapEnvironmentKey.self] }
        set { self[FancyTabBarDoubleTapEnvironmentKey.self] = newValue }
    }
}
