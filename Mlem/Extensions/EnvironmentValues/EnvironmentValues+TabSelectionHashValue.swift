//
//  EnvironmentValues+TabSelectionHashValue.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-17.
//

import Foundation
import SwiftUI

struct FancyTabSelectionHashValueEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int? { nil }
}

extension EnvironmentValues {
    var tabSelectionHashValue: Int? {
        get { self[FancyTabSelectionHashValueEnvironmentKey.self] }
        set { self[FancyTabSelectionHashValueEnvironmentKey.self] = newValue }
    }
}
