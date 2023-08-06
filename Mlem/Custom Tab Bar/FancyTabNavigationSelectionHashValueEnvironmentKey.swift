//
//  FancyTabNavigationSelectionHashValueEnvironmentKey.swift
//  Mlem
//
//  Created by Bosco Ho on 2023-08-05.
//

import Foundation
import SwiftUI

// swiftlint:disable type_name
struct FancyTabNavigationSelectionHashValueEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int? { nil }
}
// swiftlint:enable type_name

extension EnvironmentValues {
    var tabNavigationSelectionHashValue: Int? {
        get { self[FancyTabNavigationSelectionHashValueEnvironmentKey.self] }
        set { self[FancyTabNavigationSelectionHashValueEnvironmentKey.self] = newValue }
    }
}
