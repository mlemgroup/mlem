//
//  EnvironmentValues+TabReselectionHashValue.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-11-02.
//
import Foundation
import SwiftUI

struct FancyTabBarReselectionEnvironmentKey: EnvironmentKey {
    static var defaultValue: Int? { nil }
}

extension EnvironmentValues {
    var tabReselectionHashValue: Int? {
        get { self[FancyTabBarReselectionEnvironmentKey.self] }
        set { self[FancyTabBarReselectionEnvironmentKey.self] = newValue }
    }
}
